class Spree::BillingIntegration::Paymex < Spree::BillingIntegration
  attr_accessible :preferred_merchant_id, :preferred_px_ref

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
    "#{preferred_merchant_id.to_i + sum.to_i}".rjust(13,'0')
  end

end
