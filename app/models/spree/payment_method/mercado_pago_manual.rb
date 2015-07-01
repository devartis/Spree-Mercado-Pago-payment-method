class Spree::PaymentMethod::MercadoPagoManual < Spree::PaymentMethod

  preference :client_id, :string
  preference :client_secret, :string

  include ::Spree::MercadoPago::Provider

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
    Spree::MercadoPagoManualSource
  end

  def authorize(amount, source, gateway_options)
    formatted_amount = amount.to_f / 100
    money_request = provider.create_money_request(source.payer_email, formatted_amount, source.description)
    status = money_request['status']
    source.update!(mercado_pago_id: money_request['id'].try(:to_i), external_reference: money_request['external_reference'])
    success = !Spree::MercadoPago::MoneyRequestStatus.failed?(status)
    ActiveMerchant::Billing::Response.new(success, 'MercadoPagoMoneyRequest payment authorized', {status: status})
  end

  # If the money_request_status is pending, then don't capture yet
  # If the money_request_status is accepted and the payment_status is not pending, then capture
  # If the money_request_status is cancelled or rejected (#failed?), then capture
  def try_capture(payment)
    money_request_status = provider.get_money_request_status(payment.source.mercado_pago_id)
    if can_capture?(payment) and not Spree::MercadoPago::MoneyRequestStatus.pending?(money_request_status)
      payment_status = provider.get_payment_status payment.source.external_reference
      if Spree::MercadoPago::MoneyRequestStatus.failed? money_request_status or
          (Spree::MercadoPago::MoneyRequestStatus.accepted? money_request_status and
              not Spree::MercadoPago::PaymentStatus.pending? payment_status)
        begin
          payment.capture!
        rescue ::Spree::Core::GatewayError => e
          Rails.logger.error e.message
        end
      end
    end
  end

  def capture(amount, response_code, gateway_options)
    payment = Spree::Payment.find_by identifier: identifier(gateway_options[:order_id])
    money_request_status = provider.get_money_request_status(payment.source.mercado_pago_id)
    success = Spree::MercadoPago::MoneyRequestStatus.accepted?(money_request_status)
    if success
      payment_status = provider.get_payment_status payment.source.external_reference
      success &&= Spree::MercadoPago::PaymentStatus.approved?(payment_status)
      ActiveMerchant::Billing::Response.new(success, 'MercadoPago Money Request payment processed', {status: payment_status})
    else
      ActiveMerchant::Billing::Response.new(success, 'MercadoPago Money Request payment processed', {status: money_request_status})
    end
  end

  private

  def identifier(order_id)
    order_id.split('-').last
  end

end