require 'rails_helper'

RSpec.describe UserController, :type => :controller do
  context "check controller" do
    it "check create user invalid" do
      post :signup, params: {}
      expect(response.status).to eq(400)
    end

    it "checks create user ok" do
      post :signup, params: {:user => {'userName' => "dawefwea", 'userEmail' => "sgfr@swefeef.hf",
        'userPassword' => 'efe'}} #params#6 #{:id => 6}

      data = JSON.parse(response.body)
      p data
      expect(response.status).to eq(201)
      expect(data['respMsg']).to eq("Ok")
    end


    it "checks get user invalid id" do
      get :get_user , params: {:id => 'sef'}

      data = JSON.parse(response.body)
      p response.status
      expect(response.status).to eq(400)
    end

    it "checks get user ok" do
      get :get_user , params: {:id => '4'}

      data = JSON.parse(response.body)
      p response.status
      expect(response.status).to eq(200)
    end
  end
end
