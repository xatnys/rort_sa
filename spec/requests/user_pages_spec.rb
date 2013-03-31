require 'spec_helper'

describe "UserPages" do
  subject { page }

  describe "signup page" do
  	before { visit signup_path }

  	it { should have_content 'Sign up' }
  	it { should have_title full_title('Sign up') }
  end

  describe "profile page" do
    let (:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: 'Foo') }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: 'Bar') }

    describe "for existing users" do
  	
    	before { visit user_path(user) }

    	it { should have_content user.name }
    	it { should have_title user.name }
    end

    describe "for non-existing users" do
      before { visit user_path("bad") }
      it { should have_selector('div.alert.alert-notice', text: "User not found") }
    end

    describe "microposts" do
      before { visit user_path(user) }
      it { should have_content(m1.content) } 
      it { should have_content(m2.content) } 
      it { should have_content(user.microposts.count) }
    end
  end

  describe "user index" do
    before do
      sign_in FactoryGirl.create(:user)
      FactoryGirl.create(:user, name: "Bob", email: "bob@example.com")
      FactoryGirl.create(:user, name: "Ben", email: "ben@example.com")
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

    before(:all) { 30.times { FactoryGirl.create(:user) } }
    after(:all) { User.delete_all }

    it "should list all users" do
      User.paginate(page: 1, per_page: 10).each do |u|
        expect(page).to have_selector('li', text: u.name)
      end
    end

    describe "deletion links" do
      describe "as a normal user" do
        it { should_not have_link('delete') }
      end
      describe "as an admin" do
        let (:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end
        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { clink_link('delete').to change(User, :count).by(-1) }
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

  describe "signup process" do

  	before { visit signup_path }

  	let(:submit) { "Create my account" }

  	describe "using invalid information" do
  		it "should not create a user" do
  			expect { click_button submit }.not_to change(User, :count)
  		end

      describe "after submission" do
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_content('error') }
      end
  	end

  	describe "using valid information" do
  		before do
  			fill_in "Name", with: "Example User"
  			fill_in "Email", with: "user@example.com"
  			fill_in "Password", with: "foobar"
  			fill_in "Confirm Password", with: "foobar"
  		end

  		it "should create a user" do
  			expect { click_button submit }.to change(User, :count).by(1)
  		end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end
  	end
  end

  describe "edit user" do
    let (:user) { FactoryGirl.create(:user) }
    before do 
      sign_in user
      visit edit_user_path(user)
    end

    describe "when editing" do
      it { should have_content("Edit your profile") }
      it { should have_title("Edit profile") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes"} 

      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to  eql(new_name) }
      specify { expect(user.reload.email).to eql(new_email) }
    end

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true, password: user.password, 
                  password_confirmation: user.password } }
      end
      before { patch user_path(user), params }
      specify { expect(user.reload).not_to be_admin }
    end
  end

end
