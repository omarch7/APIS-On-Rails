require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  describe "GET #show" do
    before(:each) do
      @product = FactoryGirl.create :product
      get :show, params: { id: @product.id }
    end

    it "returns the information about a reporter on a hash" do
      product_response = json_response
      expect(product_response[:title]).to eql @product.title
    end

    it { expect(response).to have_http_status(200) }
  end

  describe "GET #index" do
    before(:each) do
      4.times { FactoryGirl.create :product }
      get :index
    end

    it "returns 4 records from the database" do
      products_response = json_response
      expect(products_response).to have(4).items
    end

    it { expect(response).to have_http_status(200) }
  end

  describe "POST #create" do
    context "when is successfully created" do
      before(:each) do
        user = FactoryGirl.create :user
        @product_attributes = FactoryGirl.attributes_for :product
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, product: @product_attributes }
      end

      it "renders the json representation for the product record just created" do
        product_response = json_response
        expect(product_response[:title]).to eql @product_attributes[:title]
      end

      it { expect(response).to have_http_status(201) }
    end

    context "when is not created" do
      before(:each) do
        user = FactoryGirl.create :user
        @invalid_product_attributes = { title: "Smart TV", price: -15 }
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, product: @invalid_product_attributes }
      end

      it "renders an errors json" do
        product_response = json_response
        expect(product_response).to have_key(:errors)
      end

      it "renders the json errors on the whye the user could not be created" do
        product_response = json_response
        expect(product_response[:errors][:price]).to include "must be greater than or equal to 0"
      end

      it { expect(response).to have_http_status(422) }
    end
  end

  describe "PUT/PATCH #update" do
    before(:each) do
      @user = FactoryGirl.create :user
      @product = FactoryGirl.create :product, user: @user
      api_authorization_header @user.auth_token
    end

    context "when is successfully updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @product.id, product: { title: "An expensive TV" } }
      end

      it "renders the json representation for the updated user" do
        product_response = json_response
        expect(product_response[:title]).to eql "An expensive TV"
      end

      it { expect(response).to have_http_status(200) }
    end

    context "when is not updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @product.id, product: { price: -15 } }
      end

      it "renders an errors json" do
        product_response = json_response
        expect(product_response).to have_key(:errors)
      end

      it "renders the json errors on whye the user could not be created" do
        product_response = json_response
        expect(product_response[:errors][:price]).to include "must be greater than or equal to 0"
      end

      it { expect(response).to have_http_status(422) }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      @product = FactoryGirl.create :product, user: @user
      api_authorization_header @user.auth_token
      delete :destroy, params: { user_id: @user.id, id: @product.id }
    end

    it { expect(response).to have_http_status(204) }
  end
end