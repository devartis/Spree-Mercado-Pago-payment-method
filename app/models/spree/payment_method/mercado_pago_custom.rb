class Spree::PaymentMethod::MercadoPagoCustom < Spree::PaymentMethod
  preference :app_name, :string
  preference :public_key_production, :string
  preference :access_token_production, :string
  preference :public_key_sandbox, :string
  preference :access_token_sandbox, :string
  preference :sandbox, :boolean, default: true

  scope :active, -> { where(active: true) }

  def auto_capture?
    true
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

  def purchase(amount, source, gateway_options)
    email = gateway_options[:email]
    user = Spree::User.find(gateway_options[:customer_id])
    if user.mercado_pago_customer_id
      mercado_pago_customer_id = user.mercado_pago_customer_id
    else
      mercado_pago_customer_id = provider.customers.find_or_create email
      user.update(mercado_pago_customer_id: mercado_pago_customer_id)
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
    success = is_success?(response)

    source.update(mercado_pago_id: response[:id], external_reference: response[:external_reference])

    if success and !is_known_card
      provider.customers.associate_card(mercado_pago_customer_id, source.card_token)
    end

    ActiveMerchant::Billing::Response.new(success, 'MercadoPago Custom Checkout Payment Processed', {})
  end

  private

  def is_success?(response)
    response[:status] == 'approved'
  end
end