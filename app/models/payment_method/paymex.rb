class PaymentMethod::Paymex < PaymentMethod

  preference :merchant_id, :string
  preference :url, :string, :default => "https://ssl.dotpay.pl/"

  def payment_profiles_supported?
    false
  end

end
