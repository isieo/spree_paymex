CheckoutController.class_eval do

  before_filter :redirect_for_dotpay_pl, :only => :update

  private

  def redirect_for_paymex
    return unless params[:state] == "payment"
    @payment_method = PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
    if @payment_method && @payment_method.kind_of?(Spree::PaymentMethod::Paymex)
      redirect_to paymex_proxy_path(:gateway_id => @payment_method.id, :order_id => @order.id)
    end
  end

end
