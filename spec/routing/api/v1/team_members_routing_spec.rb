require "rails_helper"

RSpec.describe Api::V1::TeamMembersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/api/v1/team_members").to route_to("api/v1/team_members#index")
    end

    it "routes to #show" do
      expect(:get => "/api/v1/team_members/1").to route_to("api/v1/team_members#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/api/v1/team_members").to route_to("api/v1/team_members#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/v1/team_members/1").to route_to("api/v1/team_members#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/v1/team_members/1").to route_to("api/v1/team_members#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/v1/team_members/1").to route_to("api/v1/team_members#destroy", :id => "1")
    end
  end
end
