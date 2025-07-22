require 'rails_helper'

RSpec.describe "Publishers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/publishers/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/publishers/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/publishers/create"
      expect(response).to have_http_status(:success)
    end
  end
end
