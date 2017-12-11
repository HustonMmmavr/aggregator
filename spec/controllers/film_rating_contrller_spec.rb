require 'rails_helper'

RSpec.describe FilmRatingController, :type => :controller do
  context "check controller" do
    it "checks set_rating film invaid" do
      post :set_rating, params: {}
      expect(response.status).to eq(400)
    end

    it "checks set_rating ok" do
      post :set_rating, params: {:userId => 4, :filmRating => 6, :filmId => 18}
      expect(response.status).to eq(200)

    end

    it "find users by film invaid id" do
      get :get_users_by_film, params: {:id => 'sfe'}
      expect(response.status).to eq(400)
    end

    it "find users by film no such recorf" do
      get :get_users_by_film, params: {:id => '1'}
      expect(response.status).to eq(404)
    end

    it "find user by film" do
      get :get_users_by_film, params: {:id => '20'}
      expect(response.status).to eq(200)
    end

    it "find films by user invaid id" do
      get :get_films_by_user, params: {:id => 'sfe'}
      expect(response.status).to eq(400)
    end

    it "find films by user no revord" do
      get :get_films_by_user, params: {:id => '100'}
      expect(response.status).to eq(404)
    end

    it "find by user " do
      get :get_films_by_user, params: {:id => '4'}
      expect(response.status).to eq(200)
    end
  end
end
