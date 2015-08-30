Spree::CheckoutController.class_eval do

  before_filter :proxy_for_paymex, :only => :update

  private

  def proxy_for_paymex
    if  params[:order][:payments_attributes] &&
        params[:order][:payments_attributes].first[:payment_method_id] &&
        Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id]).type == 'Spree::BillingIntegration::Paymex'

          order_id = params[:paymex][:PX_PURCHASE_ID].split('-').first
          @order = Spree::Order.find_by_number(order_id)
          @gateway = Spree::PaymentMethod.find(params[:paymex][:PX_CUSTOM_FIELD1])
          salt = ('a'..'z').to_a.shuffle[0..7].join
          password = @gateway.merchant_id_with_checksum(params[:paymex][:PX_PURCHASE_ID]) + @gateway.preferred_px_ref
          params[:paymex][:PX_REF] = @gateway.preferred_px_ref

          data_string = ""
          [:PX_VERSION,:PX_TRANSACTION_TYPE,
            :PX_PURCHASE_ID,:PX_PAN,
            :PX_EXPIRY,:PX_MERCHANT_ID,
            :PX_PURCHASE_AMOUNT,:PX_PURCHASE_DESCRIPTION,
            :PX_PURCHASE_DATE,:PX_CVV2,
            :PX_CUSTOM_FIELD1,:PX_CUSTOM_FIELD2,
            :PX_CUSTOM_FIELD3,:PX_CUSTOM_FIELD4,
            :PX_CUSTOM_FIELD5,:PX_REF,
            :PX_ALT_URL,:PX_POLICY_NO].each do |k|
              data_string += params[:paymex][k] if params[:paymex][k] && !params[:paymex][k].blank?
              data_string += "\n"
          end
          px_sig = (Base64.encode64(Spree::BillingIntegration::Paymex.encrypt_aes_ecb(password, data_string))).gsub("\n", "")
          @paymex_params = params[:paymex]
          @paymex_params[:PX_SIG] = px_sig
          render 'spree/paymex/proxy'
          return
    end
  end

end
