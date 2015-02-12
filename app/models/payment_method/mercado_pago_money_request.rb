class PaymentMethod::MercadoPagoMoneyRequest < Spree::PaymentMethod

  preference :client_id, :string
  preference :client_secret, :string

  include Provider
end
