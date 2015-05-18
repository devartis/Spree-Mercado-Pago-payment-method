FactoryGirl.define do
  factory :mercado_pago_payment_method, class: Spree::PaymentMethod::MercadoPagoBasic do
    name "MercadoPago Payment Method"
  end

  factory :mercado_pago_manual_payment_method, class: Spree::PaymentMethod::MercadoPagoManual do
    name "MercadoPagoManual Payment Method"
    preferred_client_id 'test'
    preferred_client_secret 'test'
  end

  factory :mercado_pago_custom_payment_method, class: Spree::PaymentMethod::MercadoPagoCustom do
    sandbox true
    preferred_public_key_sandbox 'TEST-5d26c80f-90fc-4921-8a5d-427cc2531d6a'
    preferred_access_token_sandbox 'TEST-3399440369171872-051314-774e7f2878bc1154ea77c02b3ff9af00__LD_LA__-74349919'
  end
end
