require 'digest/md5'
require 'openssl'
require "base64"
# pbe with md5 and des
class Gateway::PaymexController < Spree::BaseController



  def response 
    @order = Order.find_by_number(params[:PX_CUSTOM_FIELD1])
    @gateway = @order && @order.payments.first.payment_method
    return if !@gateway
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
      // TODO: Process the payment
      render :text => "OK"
    else
      render :text => "Not valid"
      return
    end
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
