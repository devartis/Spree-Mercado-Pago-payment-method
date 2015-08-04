class Spree::PaymentMethod::MercadoPagoCustom < Spree::PaymentMethod
  preference :app_name, :string
  preference :public_key_production, :string
  preference :access_token_production, :string
  preference :public_key_sandbox, :string
  preference :access_token_sandbox, :string
  preference :sandbox, :boolean, default: true

  scope :active, -> { where(active: true) }

  def auto_capture?
    false
  end

  def public_key
    if preferred_sandbox
      preferred_public_key_sandbox
    else
      preferred_public_key_production
    end
  end

  def access_token
    if preferred_sandbox
      preferred_access_token_sandbox
    else
      preferred_access_token_production
    end
  end

  def payment_source_class
    ::Spree::MercadoPagoCustomSource
  end

  def provider_class
    ::Spree::MercadoPago::CustomClient::Provider
  end

  def provider
    provider_class.new self.access_token
  end

  def capture(amount, source, gateway_options)
    identifier = identifier(gateway_options[:order_id])
    payment = Spree::Payment.find_by! identifier: identifier

    payment_info = get_payment_info(payment)
    result = is_success?(payment_info)
    ActiveMerchant::Billing::Response.new(result, 'MercadoPago Payment Processed', {})
  end

  def try_capture(payment)
    payment_info = get_payment_info(payment)
    unless is_pending?(payment_info)
      begin
        payment.capture!
      rescue ::Spree::Core::GatewayError => e
        Rails.logger.error e.message
      end
    end
  end

  def authorize(amount, source, gateway_options)
    email = gateway_options[:email]
    user = Spree::User.find(gateway_options[:customer_id])
    if user.mercado_pago_customer_id
      mercado_pago_customer_id = user.mercado_pago_customer_id
    else
      mercado_pago_customer_id = provider.customers.find_or_create email
      if mercado_pago_customer_id
        user.update(mercado_pago_customer_id: mercado_pago_customer_id)
      else
        Rails.logger.error("MercadoPago: There was an error creating a MP customer for user #{user.id}")
      end
    end

    is_known_card = source.integration_payment_method_id.nil?

    description = 'Compra en Avalancha'

    if is_known_card
      hash = {payer_id: mercado_pago_customer_id}
    else
      hash = {payment_method_id: source.integration_payment_method_id, payer_email: email}
    end

    formatted_amount = amount.to_f / 100
    response = provider.payments.create(formatted_amount, source.card_token, description, source.installments, hash)
    success = is_success?(response) || is_pending?(response)

    if success
      source.update(mercado_pago_id: response[:id], external_reference: response[:external_reference])
      unless is_known_card
        associated = provider.customers.associate_card(mercado_pago_customer_id, source.card_token)
        unless associated
          Rails.logger.error("MercadoPago: There was an error associating card for user #{user.id} with Mercado Pago Customer ID #{mercado_pago_customer_id}")
        end
      end
    else
      Rails.logger.error("MercadoPago: Unable to create payment. Response #{response}")
      source.save_response_error(response)
    end

    ActiveMerchant::Billing::Response.new(success, 'MercadoPago Custom Checkout Payment Authorized', {})
  end

  private

  def get_payment_info(payment)
    response = provider.payments.search({id: payment.source.mercado_pago_id})
    if response[:results].empty?
      {status: 'in_process'}
    else
      response[:results].first
    end
  end

  def is_success?(response)
    response[:status] == 'approved'
  end

  def is_pending?(response)
    response[:status] == 'in_process'
  end

  def identifier(order_id)
    order_id.split('-').last
  end

end