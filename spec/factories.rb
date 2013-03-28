FactoryGirl.define do
	factory :user do
		name		"Bob Varsha"
		email 	"bob@speed.com"
		password	"foobar"
		password_confirmation "foobar"
	end
end
