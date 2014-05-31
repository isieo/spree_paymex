CheckoutController.class_eval do

  before_filter :redirect_for_paymex, :only => :update

  private

  def redirect_for_paymex
      if  object_params[:payments_attributes] &&
          object_params[:payments_attributes].first[:payment_method_id] &&
          PaymentMethod.find(object_params[:payments_attributes].first[:payment_method_id]).type == 'Spree::BillingIntegration::Paymex'
        redirect_to paymex_proxy_path(@order, params[:paymex])
      end
  end


end
