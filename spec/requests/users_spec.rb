require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/users/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /favorites" do
    it "returns http success" do
      get "/users/favorites"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /my_podcasts" do
    it "returns http success" do
      get "/users/my_podcasts"
      expect(response).to have_http_status(:success)
    end
  end
end
