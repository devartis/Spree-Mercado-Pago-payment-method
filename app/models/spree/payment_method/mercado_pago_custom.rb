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
    ::Spree::MercadoPago::CustomClient
  end

  def provider
    provider_class.new self.access_token
  end

  def purchase(amount, source, gateway_options)
    description = 'Compra en Avalancha'
    if source.integration_payment_method_id
      # New card
      hash = {payment_method_id: source.integration_payment_method_id, payer_email: gateway_options[:email]}
      response = provider.payments.create(amount, source.card_token, description, source.installments, hash)
      success = is_success?(response)
    else
      # Known card
      user = Spree::User.find(gateway_options[:customer_id])
      hash = {payer_id: user.mercado_pago_customer_id}
      response = provider.payments.create(amount, source.card_token, description, source.installments, hash)
      success = is_success?(response)
    end

    ActiveMerchant::Billing::Response.new(success, 'MercadoPago Custom Checkout Payment Processed', {})
  end

  private

  def is_success?(response)
    true
  end
end