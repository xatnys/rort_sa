module UsersHelper
	def gravatar_for(user, options = { size: 50 } )
		digest = Digest::MD5::hexdigest(user.email.downcase)
		image_tag("https://secure.gravatar.com/avatar/#{digest}?s=#{options[:size]}", alt: user.email, class: "gravatar")
	end
end
