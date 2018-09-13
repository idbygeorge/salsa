class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    before_save { self.email = email.downcase }
    validates :name, presence: true, length: { maximum: 50 }
    validates :name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
    # validates :password, presence: true, length: { minimum: 8 }

    has_secure_password

    has_many :user_assignments

    def activate
      if !self.activated
        self.activation_digest = nil
        self.activated_at = DateTime.now
        self.activated = true
        self.save
      end
    end
end
