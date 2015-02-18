FactoryGirl.define do
  factory :mercado_pago_payment_method, class: PaymentMethod::MercadoPago do
    name "MercadoPago Payment Method"
  end

  factory :mercado_pago_manual_payment_method, class: PaymentMethod::MercadoPagoManual do
    name "MercadoPagoManual Payment Method"
    preferred_client_id 'test'
    preferred_client_secret 'test'
  end
end
