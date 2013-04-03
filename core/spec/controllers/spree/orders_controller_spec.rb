require 'spec_helper'

describe Spree::OrdersController do
  let(:user) { create(:user) }
  let(:order) { mock_model(Spree::Order, :number => "R123", :reload => nil, :save! => true, :coupon_code => nil, :user => user, :completed? => false, :currency => "USD", :token => 'a1b2c3d4')}
  before do
    # Don't care about IP address being set here
    order.stub(:last_ip_address=)
    Spree::Order.stub(:find).with(1).and_return(order)
    #ensure no respond_overrides are in effect
    if Spree::BaseController.spree_responders[:OrdersController].present?
      Spree::BaseController.spree_responders[:OrdersController].clear
    end

    controller.stub(:try_spree_current_user => user)
  end

  context "#populate" do
    before { Spree::Order.stub(:new).and_return(order) }

    it "should create a new order when none specified" do
      Spree::Order.should_receive(:new).and_return order
      spree_post :populate, {}, {}
      session[:order_id].should == order.id
    end

    context "with Variant" do
      let(:populator) { double('OrderPopulator') }
      before do
        Spree::OrderPopulator.should_receive(:new).and_return(populator)
      end

      it "should handle single variant/quantity pair" do
        populator.should_receive(:populate).with("variants" => { 1 => "2" }).and_return(true)
        spree_post :populate, { :order_id => 1, :variants => { 1 => 2 } }
        response.should redirect_to spree.cart_path
      end

      it "should handle multiple variant/quantity pairs with shared quantity" do
        populator.should_receive(:populate).with("products" => { 1 => "2" }, "quantity" => "1").and_return(true)
        spree_post :populate, { :order_id => 1, :products => { 1 => 2 }, :quantity => 1 }
        response.should redirect_to spree.cart_path
      end
    end
  end

  context "#update" do
    before do
      order.stub(:update_attributes).and_return true
      order.stub(:line_items).and_return([])
      order.stub(:line_items=).with([])
      order.stub(:last_ip_address=)
      Spree::Order.stub(:find_by_id_and_currency).and_return(order)
    end

    it "should not result in a flash success" do
      spree_put :update, {}, {:order_id => 1}
      flash[:success].should be_nil
    end

    it "should render the edit view (on failure)" do
      order.stub(:update_attributes).and_return false
      order.stub(:errors).and_return({:number => "has some error"})
      spree_put :update, {}, {:order_id => 1}
      response.should render_template :edit
    end

    it "should redirect to cart path (on success)" do
      order.stub(:update_attributes).and_return true
      spree_put :update, {}, {:order_id => 1}
      response.should redirect_to(spree.cart_path)
    end
  end

  context "#empty" do
    it "should destroy line items in the current order" do
      controller.stub!(:current_order).and_return(order)
      order.should_receive(:empty!)
      spree_put :empty
      response.should redirect_to(spree.cart_path)
    end
  end

  #TODO - move some of the assigns tests based on session, etc. into a shared example group once new block syntax released
end
