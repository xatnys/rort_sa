class User < ActiveRecord::Base

	has_many :microposts, dependent: :destroy
	has_many :relationships, foreign_key: "follower_id", dependent: :destroy
	has_many :followed_users, through: :relationships, source: :followed

	has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy
	has_many :followers, through: :reverse_relationships, source: :follower

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
    # Micropost.where("user_id = ?", id)
    Micropost.from_users_followed_by(self)
  end

  def following?(other_user)
  	self.relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
  	self.relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
		self.relationships.find_by(followed_id: other_user.id).destroy
	end

	private
		def create_remember_token
			self.remember_token = SecureRandom.urlsafe_base64
		end
end
