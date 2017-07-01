require 'net/http'
class RepublishController < ApplicationController
  before_action :require_admin_permissions
  def preview
    get_documents
    @organizations = Organization.all.order(:lft, :rgt, :name)

    if !@organization.republish_batch_token
      @organization.republish_batch_token = SecureRandom.urlsafe_base64(16)
    end
    @organization.save!

    render :layout => 'admin', :template => '/republish/preview'
  end

  def update_lock
    expire = params[:expire]
    @organization = find_org_by_path params[:slug]
    if !expire
      @organization.republish_at = DateTime.now

      @organization.save!

      respond_to do |format|
        msg = { :status => "ok", :message => "Success!" }
        format.html  {
          render :json => msg
        }
      end
    else
      expire_lock
    end
  end

  def expire_lock
    @organization.republish_at = nil
    @organization.republish_batch_token = nil
    @organization.save!
  end

  private

  def get_documents path=params[:slug], page=params[:page], per=25, start_date=params[:document][:start_date], end_date=params[:document][:end_date]
    operation = '';
    if start_date && start_date != ''
      operation += "AND lms_published_at >= '#{DateTime.parse(start_date).beginning_of_day}' ";
    end

    if end_date && end_date != ''
      operation += "AND lms_published_at <= '#{DateTime.parse(end_date).end_of_day}'"
    else
      operation += "AND lms_published_at <= '#{DateTime.now.end_of_day}'"
    end
    if path
      @organization = find_org_by_path path

      documents = Document.where("documents.organization_id=? #{operation} AND documents.updated_at != documents.created_at", @organization[:id])
    else
      documents = Document.where("documents.organization_id IS NULL #{operation} AND documents.updated_at != documents.created_at")
    end
    @republish_urls = []
    ids =  documents.pluck(:edit_id)

    ids.each do |id|
    @republish_urls.push("//#{path}#{redirect_port}/SALSA/" + id)
    end

    @documents = documents.order(updated_at: :desc, created_at: :desc).page(page).per(per)

  end
end
