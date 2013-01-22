module Spree
  class PaymexController < ::ActionController::Base

    def response_handler
      if params[:PX_PURCHASE_ID].nil?
        error_message = "Invalid purchase, please contact customer support."
        flash[:error] = error_message
        @order = Spree::Order.find(session[:order_id])
        redirect_to checkout_state_path(@order.state)
        return
      end
      @order = Spree::Order.find_by_number(params[:PX_PURCHASE_ID])

      if params[:PX_ERROR_CODE].empty? || params[:PX_ERROR_CODE] == '000'
        salt = Base64.decode64 params[:PX_SIG][0..11]
        data = Base64.decode64 params[:PX_SIG][12..-1]
        @gateway = Spree::PaymentMethod.find(params[:PX_CUSTOM_FIELD1])
        px_ref = @gateway.preferred_px_ref
        password = @gateway.preferred_merchant_id.rjust(13,'0') + px_ref
        decrypted = self.decrypt_pbe_with_md5_and_des(password, salt, data).split("\n")
        valid = true
        i = 0
        [:PX_VERSION, :PX_TRANSACTION_TYPE,
        :PX_PURCHASE_ID, :PX_PAN,
        :PX_PURCHASE_AMOUNT, :PX_ERROR_CODE,
        :PX_ERROR_DESCRIPTION, :PX_APPROVAL_CODE,
        :PX_RRN, :PX_CUSTOM_FIELD1,
        :PX_CUSTOM_FIELD2, :PX_CUSTOM_FIELD3,
        :PX_CUSTOM_FIELD4, :PX_CUSTOM_FIELD5].each do |key|
          if params[key] != decrypted[i]
            valid = false
            break
          end
          i+=1
          break if i >= decrypted.count
        end

        if valid

          credit_card = Spree::Creditcard.new(month: 1,year: 2030, :verification_value=>'000',number: params[:PX_PAN] )
          credit_card.save
          @order.payments.create(
                :amount => params[:PX_PURCHASE_AMOUNT].to_f / 100,
                :source => credit_card.id,
                :source_type => 'Spree::Creditcard',
                :payment_method_id => @gateway.id,
                :response_code => params[:PX_RRN],
                :avs_response => params[:PX_APPROVAL_CODE])

          @order.payment.started_processing!
          @order.payment.log_entries.create(:details => params.except(:PX_PAN).to_yaml)
          if @order.total.to_f == params[:PX_PURCHASE_AMOUNT].to_f/100
            @order.payment.complete!
          end
          @order.update_attributes({:state => "complete", :completed_at => Time.now}, :without_protection => true)

          # Since we dont rely on state machine callback, we just explicitly call this method for spree_store_credits
          if @order.respond_to?(:consume_users_credit, true)
            @order.send(:consume_users_credit)
          end

          @order.finalize!
          flash[:notice] = I18n.t(:order_processed_successfully)
          flash[:commerce_tracking] = "true"
          redirect_to order_url(@order, {:checkout_complete => true, :order_token => @order.token}), :notice => I18n.t("payment_success")
          return
        end
      end

      error_message = "Error Processing payment, We are unable to process your payment, please contact customer support."
      error_message += "Payment gateway message: #{params[:PX_ERROR_DESCRIPTION]}" if params[:PX_ERROR_DESCRIPTION]
      flash[:error] = error_message
      redirect_to checkout_state_path('payment')
    end


  protected
     def decrypt_pbe_with_md5_and_des(password, salt, data)
        require 'digest/md5'
        require 'openssl'
        require "base64"
        # pbe with md5 and des
       des=OpenSSL::Cipher::Cipher.new("des")
       des.pkcs5_keyivgen password, salt, 1000, 'MD5'
       des.decrypt
       d = des.update(data)
       d << des.final
     end
  end
end
