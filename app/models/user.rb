class User < ApplicationRecord
  devise :saml_authenticatable

  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  # validates :password, presence: true, length: { minimum: 8 }

  has_many :user_assignments
  has_many :documents
  has_secure_password

  has_many :user_assignments

  def self.saml_resource_locator(model, saml_response, auth_value)
    user = UserAssignment.find_by("lower(username) = ?", auth_value.to_s.downcase)&.user
    user = User.find_by(email: saml_response.attribute_value_by_resource_key("email")) if user.blank?
    return user
  end


  def self.saml_update_resource_hook(user, saml_response, auth_value)
    saml_response.attributes.resource_keys.each do |key|
      case key
      when /(first_name|last_name)/
        user.send "name=", "#{saml_response.attribute_value_by_resource_key("first_name")} #{saml_response.attribute_value_by_resource_key("last_name")}"
      when /id/
        org = Organization.find_by(slug: URI.parse(saml_response.raw_response.destination).host)
        ua = user.user_assignments.find_by(organization_id: org.descendants.map(&:id))
        ua = UserAssignment.find_or_initialize_by(user_id: user.id, organization_id: org.id ) if ua.blank?
        if ua.new_record? || ua.username.blank?
          ua.username = saml_response.attribute_value_by_resource_key(key)
          ua.role = "staff" if ua.role.blank?
          user.archived = true if ua.new_record?

          UserMailer.new_unassigned_user_email(user, org, {"user_name" => "#{user&.name}","user_email" => "#{user&.email}", "organization_name" => "#{org&.name}", "archived_users_url" => "#{org.full_slug}/admin/organization/#{org.full_slug}/users?show_archived=true"}).deliver_later if ua.new_record?
          ua.save
        end
      else
        user.send "#{key}=", saml_response.attribute_value_by_resource_key(key)
      end
    end

    user.send "password=", SecureRandom.urlsafe_base64

    if (Devise.saml_use_subject)
      user.send "#{Devise.saml_default_user_key}=", auth_value
    end

    user.save!
  end

  # def self.authenticate_with_saml(saml_response, relay_state)
  #   super
  # end

  def activate
    if !self.activated
      self.activation_digest = nil
      self.activated_at = DateTime.now
      self.activated = true
      self.save
    end
  end
end
