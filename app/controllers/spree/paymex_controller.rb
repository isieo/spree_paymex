require 'digest/md5'
require 'openssl'
require "base64"
# pbe with md5 and des
class Spree::PaymexController < Spree::BaseController

  def response 
    if params[:PX_PURCHASE_ID].nil?
      return 
    end
    @order = Spree::Order.find_by_number(params[:PX_PURCHASE_ID])
    
    salt = Base64.decode64 params[:PX_SIG][0..11]
    data = Base64.decode64 params[:PX_SIG][12..-1]
    px_ref = Digest::MD5.hexdigest(@order.number)[0..7]
    password = @gateway.preferred_merchant_id + px_ref
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
    end
    
    if valid
      @order.payment.started_processing
      if @order.total.to_f == params[:PX_PURCHASE_AMOUNT].to_f
        @order.payment.response_code = params[:PX_APPROVAL_CODE]
        @order.payment.complete
      end 
      
      @order.finalize!
      @order.next
      @order.next
      @order.save
      redirect_to order_url(@order, {:checkout_complete => true, :order_token => @order.token}), :notice => I18n.t("payment_success")
      return
    end
    
    error_message = "Error Processing payment, please contact customer support."
    error_message = params[:PX_ERROR_DESCRIPTION] if params[:PX_ERROR_DESCRIPTION]
    redirect_to order_url(@order, {:checkout_complete => false, :order_token => @order.token}), :error => error_message
  end


private
   def decrypt_pbe_with_md5_and_des(password, salt, data)
     des=OpenSSL::Cipher::Cipher.new("des")
     des.pkcs5_keyivgen password, salt, 1000, 'MD5'
     des.decrypt
     d = des.update(enc_data)
     d << des.final
   end
end
