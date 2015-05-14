class PaymentMethod::MercadoPago::CustomCheckout < Spree::PaymentMethod
  preference :app_name, :string
  preference :public_key_production, :string
  preference :access_token_production, :string
  preference :public_key_sandbox, :string
  preference :access_token_sandbox, :string
  preference :sandbox, :boolean, default: true

  scope :active, -> { where(active: true) }

  include ::MercadoPago::CustomCheckout::PaymentIntegration

  def payment_source_class
    ::MercadoPago::CustomCheckout::Source
  end

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
end