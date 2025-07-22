require 'rails_helper'

RSpec.describe "Podcasts", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/podcasts/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/podcasts/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/podcasts/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/podcasts/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/podcasts/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/podcasts/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/podcasts/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /search" do
    it "returns http success" do
      get "/podcasts/search"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /favorite" do
    it "returns http success" do
      get "/podcasts/favorite"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /unfavorite" do
    it "returns http success" do
      get "/podcasts/unfavorite"
      expect(response).to have_http_status(:success)
    end
  end
end
