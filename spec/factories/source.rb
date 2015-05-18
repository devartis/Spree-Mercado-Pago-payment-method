FactoryGirl.define do
  factory :mercado_pago_manual_source, class: Spree::MercadoPagoManualSource do
    payer_email 'test@test.com'
    external_reference '12345'
    mercado_pago_id '12345'
  end
end