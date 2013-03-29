require 'spec_helper'

describe "Authentication" do
  
  subject { page } 
  describe "sign-in process" do
  	let(:user) { FactoryGirl.create(:user) }
  	before { visit signin_path }

  	it { should have_content('Sign in') }
  	it { should have_title('Sign in') }

  	describe "using invalid information" do
  		before do
  			click_button "Sign in"
  		end

  		it { should have_content('Sign in') }
  		it { should have_selector('div.alert.alert-error', text: 'Invalid') }

  		describe "after visiting another page" do
 				before { click_link "Home" }
 		  	it { should_not have_selector('div.alert.alert-error') }
			end

  	end

  	describe "using valid information" do
  		before do
  			fill_in "Email", with: user.email.upcase
  			fill_in "Password", with: user.password
  			click_button "Sign in"
  		end
  		it { should have_title(user.name) }
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Sign out',    href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end
  end
end
