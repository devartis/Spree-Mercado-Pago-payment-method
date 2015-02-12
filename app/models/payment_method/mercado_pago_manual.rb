class PaymentMethod::MercadoPagoManual < Spree::PaymentMethod

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
    MercadoPagoManualSource
  end

  def authorize(amount, source, gateway_options)
    ActiveMerchant::Billing::Response.new(true, 'MercadoPagoMoneyRequest payment authorized', {})
  end

  def try_capture(payment)
    response = provider.get_money_request_status(payment.source.mercado_pago_id)
    if can_capture?(payment) and not pending?(response)
      begin
        payment.capture!
      rescue ::Spree::Core::GatewayError => e
        Rails.logger.error e.message
      end
    end
  end

  def capture(amount, source, gateway_options)
    response = provider.get_money_request_status source.mercado_pago_id
    success = accepted?(response)
    ActiveMerchant::Billing::Response.new(success, 'MercadoPago payment processed', {status: status})
  end

  private

  def pending?(response)
    response['status'] == 'pending'
  end

  def failed?(response)
    ['rejected', 'cancelled'].include? response['status']
  end

  def accepted?(response)
    response['status'] == 'accepted'
  end
end