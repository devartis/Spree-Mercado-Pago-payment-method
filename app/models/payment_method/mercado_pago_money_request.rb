class PaymentMethod::MercadoPagoMoneyRequest < Spree::PaymentMethod

  preference :client_id, :string
  preference :client_secret, :string

  include Provider

  def payment_profiles_supported?
    false
  end

  def can_void?(payment)
    !payment.void?
  end

  def can_capture?(payment)
    payment.pending? || payment.checkout?
  end

  def auto_capture?
    false
  end

  def payment_source_class
    nil
  end

  def authorize(amount, response_code, gateway_options)
    ActiveMerchant::Billing::Response.new(true, 'MercadoPagoMoneyRequest payment authorized', {})
  end

  private
  def pending?(status)
    status == 'pending'
  end

  def failed?(status)
    status == 'rejected' or status == 'cancelled'
  end

  def accepted?(status)
    status == 'accepted'
  end
end
