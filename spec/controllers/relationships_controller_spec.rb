require 'spec_helper'

describe RelationshipsController do

	let(:following_user) { FactoryGirl.create(:user) }
	let(:followed_user) { FactoryGirl.create(:user) }

	before { sign_in following_user }

	describe "creating a relationship via xhr" do
		it "should increment the Relationship count" do
			expect do
				xhr :post, :create, :relationship => { followed_id: followed_user.id }
			end.to change(Relationship, :count).by(1)
		end

		it "should respond with success" do
			xhr :post, :create, :relationship => { followed_id: followed_user.id }
			expect(response).to be_success
		end
	end

	describe "destroying a relationship via xhr" do

		before { following_user.follow!(followed_user) }
		let(:relationship) { following_user.relationships.find_by(followed_id: followed_user) }

		it "should decrement the Relationship" do
			expect do
				xhr :delete, :destroy, :id => relationship.id
			end.to change(Relationship, :count).by(-1)
		end

		it "should respond with success" do
			xhr :delete, :destroy, :id => relationship.id
			expect(response).to be_success
		end
	end

end