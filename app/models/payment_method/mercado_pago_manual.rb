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
    formatted_amount = amount.to_f / 100
    response = provider.create_money_request(source.payer_email, formatted_amount, source.description)
    status = response['status']
    success = !failed?(status)
    source.mercado_pago_id = response['id'].try(:to_i)
    source.external_reference = response['external_reference']
    source.save!
    ActiveMerchant::Billing::Response.new(success, 'MercadoPagoMoneyRequest payment authorized', {status: status})
  end

  def try_capture(payment)
    status = provider.get_money_request_status(payment.source.mercado_pago_id)
    if can_capture?(payment) and not pending?(status)
      begin
        payment.capture!
      rescue ::Spree::Core::GatewayError => e
        Rails.logger.error e.message
      end
    end
  end

  def capture(amount, source, gateway_options)
    status = provider.get_money_request_status source.mercado_pago_id
    success = accepted?(status)
    ActiveMerchant::Billing::Response.new(success, 'MercadoPago payment processed', {status: status})
  end

  private

  def identifier(order_id)
    order_id.split('-').last
  end

  def pending?(status)
    status == 'pending'
  end

  def failed?(status)
    %w(rejected cancelled).include? status
  end

  def accepted?(status)
    status == 'accepted'
  end
end