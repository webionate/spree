require 'spec_helper'

describe Spree::Admin::RefundsController do
  stub_authorization!

  describe "POST create" do
    context "a Spree::Core::GatewayError is raised" do

      let(:payment) { create(:payment) }

      subject do
        spree_post :create,
                   refund: { amount: "50.0", refund_reason_id: "1" },
                   payment_id: payment.id
      end

      before(:each) do
        def controller.create
          raise Spree::Core::GatewayError.new('An error has occurred')
        end
      end

      it "sets an error message with the correct text" do
        subject
        expect(flash[:error]).to eq 'An error has occurred'
      end

      it { should render_template(:new) }
    end
  end
end
