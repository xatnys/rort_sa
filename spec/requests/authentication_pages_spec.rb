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
  		before { sign_in user }

  		it { should have_title(user.name) }
      it { should have_link('Users', href: users_path) }
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Sign out',    href: signout_path) }
      it { should have_link('Settings', href: edit_user_path(user) )}
      it { should_not have_link('Sign in', href: signin_path) }
      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end
  end

  describe "authorization" do
    describe "for non-signed in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "there should be no user links" do
        it { should_not have_link('Users', href: users_path) }
        it { should_not have_link('Profile') }
        it { should_not have_link('Sign out') }
        it { should_not have_link('Settings') }
      end

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do 
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

      describe "accessing a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do
          it "should render the expected protected page" do
            expect(page).to have_title('Edit profile')
          end
          describe "sign in again" do
            before { sign_in user }
            it "should take user to the profile instead of the protected page" do
              expect(page).to have_title("Profile: #{user.name}")
            end
          end
        end
      end

      describe "visiting the user index" do
        before { visit users_path }
        it { should have_title("Sign in") }
      end

    end

    describe "for signed-in users without admin" do
      let(:normal_user) { FactoryGirl.create(:user) }
      before { sign_in normal_user }

      describe "trying to create a new user" do
        before { visit new_user_path }
        specify { expect(page).to have_title("Profile") }
      end

      describe "trying to edit another user's profile" do
        let(:different_user) { FactoryGirl.create(:user, email: 'nope@nope.com') }
        
        describe "by visiting Users#edit page" do
          before { visit edit_user_path(different_user) }
          it { should_not have_title(full_title('Edit profile')) }
        end

        describe "by submitting a PATCH request" do
          before { patch user_path(different_user) }
          specify { expect(response).to redirect_to(root_path) }
        end

        describe "deletion by submitting DELETE to Users#destroy" do
          before { delete user_path(different_user) }
          specify { expect(response).to redirect_to(root_path) }
        end
      end
    end
    describe "for admins" do
      let(:admin) { FactoryGirl.create(:admin) }
      before { sign_in admin }
      describe "trying to destroy themselves" do
        before { delete user_path(admin) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end
  end
end
