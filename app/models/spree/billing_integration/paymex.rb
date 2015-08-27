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


  def self.decrypt_aes_ecb(key,data)
    require 'openssl'
    require 'digest/sha1'
    password = Digest::SHA1.hexdigest key
    de_cipher = OpenSSL::Cipher::Cipher.new("AES-256-ECB")
    de_cipher.decrypt;
    de_cipher.key = password

    de_cipher.update([data].pack('H*')) << de_cipher.final
  end

  def self.encrypt_aes_ecb(key,data)
    require 'openssl'
    require 'digest/sha1'
    password = Digest::SHA1.hexdigest key
    cipher = OpenSSL::Cipher::Cipher.new("AES-256-ECB")
    cipher.encrypt
    cipher.key = password

    cipher.update([data].pack('H*')) << cipher.final
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
