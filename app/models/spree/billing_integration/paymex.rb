class Spree::BillingIntegration::Paymex < Spree::BillingIntegration
  #attr_accessible :preferred_merchant_id, :preferred_px_ref

  preference :merchant_id, :string
  preference :px_ref, :string

  def payment_profiles_supported?
    false
  end

  def merchant_id_with_checksum(order_id)
    sum = 0
    order_id.split(//).each do |c|
      sum += c.ord
    end
    sum = sum.to_i
    sum -= 1000 if sum > 999
    "#{preferred_merchant_id.to_i + sum.to_i}".rjust(13,'0')
  end

  def self.decrypt_pbe_with_md5_and_des(password, salt, data)
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

  def self.ecrypt_pbe_with_md5_and_des(password, salt, data)
     require 'digest/md5'
     require 'openssl'
     require "base64"
     # pbe with md5 and des
    des=OpenSSL::Cipher::Cipher.new("des")
    des.pkcs5_keyivgen password, salt, 1000, 'MD5'
    des.encrypt
    d = des.update(data)
    d << des.final
  end

end
