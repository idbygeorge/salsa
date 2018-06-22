module CanvasHelper

  def self.courses_sync_as_job (org_slug, canvas_token, account_ids=nil)
    CanvasSyncCourseMeta.enqueue(org_slug, canvas_token, account_ids)
  end

  def self.courses_sync (org_slug, canvas_token, account_ids=nil)
    org = Organization.find_by slug: org_slug
    canvas_access_token = canvas_token

    if org
      canvas_endpoint = org[:lms_authentication_source]

      canvas_client = Canvas::API.new(:host => canvas_endpoint, :token => canvas_access_token)

      if canvas_client
        if account_ids !=nil
          canvas_accounts = OrganizationMeta.where(root_id: org['id'], key: ['id', 'parent_id'],lms_account_id: account_ids.split(/,/)).order :key
        else
          canvas_accounts = OrganizationMeta.where(root_id: org['id'], key: ['id', 'parent_id']).order :key
        end
        sync_canvas_courses canvas_accounts, org[:id], canvas_client
      else
        throw "Failed to initialize canvas client: #{canvas_endpoint}"
      end
    else
      throw "Organization #{org_slug} was not found. Aborting."
    end
  end

  def self.sync_canvas_courses (accounts, root_org_id, canvas_client)
    accounts.each do |account_meta|
      if account_meta.key == 'id' then
        account = account_meta[:value]
      elsif account_meta.key == 'parent_id'
        account_parent = account_meta[:value]
      end

      #TODO need a way to deal with huge accounts... later
      if account_meta.key == 'id' && account != '90334' then
        # get all courses for the current acocunt
        begin
          canvas_courses = canvas_client.get("/api/v1/accounts/#{account}/courses?per_page=50&with_enrollments=true&include[]=total_students")
          pg = 0
          while canvas_courses.more?
            pg+=1
            puts "getting account #{account} courses (page #{pg})"
            canvas_courses.next_page!
          end

          # store each piece of data into the organization meta model
          canvas_courses.each do |course|
            puts "getting course #{course['id']} data"

            course.each do |key, value|
              meta = DocumentMeta.find_or_initialize_by key: key,
                root_organization_id: root_org_id,
                lms_organization_id: account,
                lms_course_id: course['id'].to_s

              meta[:value] = value.to_s

              meta.save
            end
          end
        rescue Exception => e
          throw "Canvas sync failed on #{account}"
        end
      end
    end
  end
end
