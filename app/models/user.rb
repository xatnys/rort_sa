class User < ActiveRecord::Base

	has_many :microposts, dependent: :destroy

	validates :name, presence: true, length: { maximum: 20 }
	
	EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, format: { with: EMAIL_REGEX }, 
		uniqueness: { case_sensitive: false }
	# make sure email is lowercase before saving
	before_save { self.email.downcase! }

	validates :password, length: { minimum: 6 }
	validates :password_confirmation, presence: true
	has_secure_password

	before_save :create_remember_token

	def feed
		# This is preliminary. See "Following users" for the full implementation.
    Micropost.where("user_id = ?", id)
  end

	private
		def create_remember_token
			self.remember_token = SecureRandom.urlsafe_base64
		end
end
