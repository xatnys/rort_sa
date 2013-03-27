class User < ActiveRecord::Base
	has_secure_password

	EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, format: { with: EMAIL_REGEX }, 
		uniqueness: { case_sensitive: false }
	# make sure email is lowercase before saving
	before_save { self.email.downcase! }

	validates :name, presence: true, length: { maximum: 20 }



	

	
	validates :password_confirmation, presence: true

	validates :password, presence: true, length: { minimum: 6 }
end
