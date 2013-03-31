require 'spec_helper'

describe User do

	before { @user = User.new(name:'example', email: 'user@example.com', password: "foobar", password_confirmation: "foobar")}
  # pending "add some examples to (or delete) #{__FILE__}"
  subject { @user }
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should be_valid }
  
  describe "with admin privileges" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when name isn't present" do
  	before { @user.name = '' }
  	it { should_not be_valid }
  end
  describe "when email isn't present" do
  	before { @user.email = '' }
  	it { should_not be_valid }
  end

  describe "when password is blank" do
    before { @user.password = @user.password_confirmation = '' }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "when password doesn't match password_confirmation" do
    before { @user.password_confirmation = "fibbar" }
    it { should_not be_valid }
  end

  describe "when password is too short" do
    before { @user.password = @user.password_confirmation = 'b' * 5 }
    it { should be_invalid }
  end

  describe "return value of authentication method" do
    before { @user.save }
    let (:user_from_db) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eql( user_from_db.authenticate( @user.password )) }
    end

    describe "with invalid password" do
      let(:user_invalid_pw) { user_from_db.authenticate("invalid") }

      it { should_not eql( user_invalid_pw ) }
      specify { expect( user_invalid_pw ).to be_false }
    end
  end


  describe "name length > 20" do
  	before { @user.name = 'b' * 21 }
  	it { should_not be_valid }
  end

  describe "when using bad emails" do
  	it "should be invalid" do
  		addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com fizz@buh..com]
  		addresses.each do |bad|
  			@user.email = bad
  			expect(@user).not_to be_valid
  		end
  	end
  end
	describe "when using good emails" do
  	it "should be valid" do
  		addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
  		addresses.each do |good|
  			@user.email = good
  			expect(@user).to be_valid
  		end
  	end
  end

  describe "when using existing email" do
  	before do
  		bad_person = @user.dup
  		bad_person.email = @user.email.upcase
  		bad_person.save
  	end
  	
  	it { should_not be_valid }
  end

  describe "when using mixed case emails" do
    let (:mixed) { "fOo@BaR.COM" }

    it "should be lowercase upon saving to database" do
      @user.email = mixed;
      @user.save
      expect(@user.reload.email).to eql(mixed.downcase)
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "micropost associations" do
    before { @user.save }
    let!(:older_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago) }
    let!(:newer_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago) }

    it "should list microposts chronologically in descending order" do
      expect(@user.microposts.to_a).to eql([newer_micropost,older_micropost])
    end

    it "destroying user should destroy associated microposts" do
      microposts = @user.microposts.dup.to_a #duplicate @user.microposts to array
      @user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty # access the Micropost model's table to check for orphaned microposts 
      end
    end

    describe "status" do
      let(:unfollowed_post) { FactoryGirl.create(:micropost, user: FactoryGirl.create(:user)) }
      
      its(:feed) { should include(older_micropost) }
      its(:feed) { should include(newer_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
    end
  end
end
