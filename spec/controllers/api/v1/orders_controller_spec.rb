require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :controller do
  describe "GET #index" do
    before(:each) do
      current_user = FactoryGirl.create :user
      api_authorization_header current_user.auth_token
      4.times { FactoryGirl.create :order, user: current_user }
      get :index, params: { user_id: current_user.id }
    end

    it "returns 4 order records from the user" do
      orders_response = json_response
      expect(orders_response).to have(4).items
    end

    it { expect(response).to have_http_status(200) }
  end

  describe "GET #show" do
    before(:each) do
      current_user = FactoryGirl.create :user
      api_authorization_header current_user.auth_token
      @order = FactoryGirl.create :order, user: current_user
      get :show, params: { user_id: current_user.id, id: @order.id }
    end

    it "returns the user order record matching the id" do
      orders_response = json_response
      expect(orders_response[:id]).to eql @order.id
    end

    it { expect(response).to have_http_status(200) }
  end
end
