require 'spec_helper'

describe "Static pages" do
let(:title) { "Ruby on Rails Tutorial Sample App" }
  
  subject{ page }

  shared_examples_for "static pages" do
    it { should have_content(heading) }
    it { should have_title(full_title(page_title)) }
  end
  

  describe "Home page" do
    before { visit root_path }

    let(:heading) { 'Sample App' }
    let(:page_title) { '' }
    it_should_behave_like "static pages"
    it { should_not have_title('Home') }

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "pagination" do
        before do 
          50.times {|x| FactoryGirl.create(:micropost, user: user, content: "#{x}") }
          visit root_path
        end
        specify{ expect(page).to have_selector("div.pagination") }
      end
      describe "micropost count" do
        it "should exist" do
          expect(page).to have_selector("span", text: "micropost")
        end
        before do 
          FactoryGirl.create(:micropost, user: user, content: "blah")
          visit root_path
        end
        it "should be plural for more than 1 micropost" do
            expect(page).to have_selector("span", text: "microposts")
        end
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }
    it_should_behave_like "static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading) { 'About Us' }
    let(:page_title) { 'About Us' }
    it_should_behave_like "static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading) { 'Contact' }
    let(:page_title) { 'Contact' }
    it_should_behave_like "static pages"
  end

it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_title(full_title('About Us'))
    click_link "Help"
    expect(page).to have_title(full_title('Help'))
    click_link "Contact"
    expect(page).to have_title(full_title('Contact'))
    click_link "Home"
    expect(page).to have_title(full_title(''))
    click_link "Sign up now!"
    expect(page).to have_title(full_title('Sign up'))
    click_link "sample app"
    expect(page).to have_title(full_title(''))
    click_link "Sign in"
    expect(page).to have_title(full_title('Sign in'))
  end  
end