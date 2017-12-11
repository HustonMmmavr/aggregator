require 'rails_helper'

RSpec.describe FilmController, :type => :controller do
  context "check controller" do
    it "checks get film (by id) which dosent exist" do
      get :film, params: {'id' => 100} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(404)
      expect(data['respMsg']).to eq("No such film")
    end

    it "check get film invalid id" do
      get :film, params: {'id' => 'fsd'} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(data['respMsg']).to eq("id is invalid")
    end

    it "checks get user (by id) ok" do
      get :film, params: {'id' => 20} #params#6 #{:id => 6}

      p response.body
      data = JSON.parse(response.body)
      p data
      expect(response.status).to eq(200)
      expect(data['respMsg']).to eq("Ok")
      expect(data['data']['filmId']).to eq(20)
    end

    it "checks film count" do
      get :get_films_count
      data = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(data['respMsg']).to eq("Ok")
      p data['filmsCount']
    end

    # it "checks get films invalid page" do
    #   get :films, params: => {:page}
    # end

    it "checks get films ok" do
      get :films, params: {:page => 1}
      data = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(data['respMsg']).to eq("Ok")
    end

    it "checks add film ivalid data" do
      post :add_film, params: {:filmName => "Name"}
      data = JSON.parse(response.body)
      expect(response.status).to eq(400)
    end

    it "check add film ok" do
      post :add_film, :params => { :film => {:filmTitle => "Title", :filmAbout => "About",
                    :filmLength => "1", :filmYear => "7", :filmDirector => "Directo", }}
      data = JSON.parse(response.body)
      p data
      @id = data['data']
      p 'a'
      p @id
      expect(response.status).to eq(201)
      expect(data['respMsg']).to eq("Ok")
    end

    it "checks delete film invalid" do
      delete :delete_film, params: {:id => 'asfe'}
      data = JSON.parse(response.body)
      expect(response.status).to eq(400)
      expect(data['respMsg']).to eq("filmId is not a digit")
    end

    it "checks delete film ok" do
      post :add_film, :params => { :film => {:filmTitle => "Title", :filmAbout => "About",
                  :filmLength => "1", :filmYear => "7", :filmDirector => "Directo", }}
      data = JSON.parse(response.body)
      @id = data['data']

      delete :delete_film, params: {:id => @id}
      data = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(data['respMsg']).to eq("Ok")
    end
  end
end
