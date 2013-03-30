include ApplicationHelper

def sign_in(user)
	visit signin_path
	fill_sign_in_form(user)
end

def fill_sign_in_form(user)
  fill_in "Email", with: user.email.upcase
  fill_in "Password", with: user.password
  click_button "Sign in"

  #Sign in without capybara
  cookies[:remember_token] = user.remember_token
end