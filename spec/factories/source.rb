FactoryGirl.define do
  factory :mercado_pago_manual_source, class: Spree::MercadoPagoManualSource do
    payer_email 'test@test.com'
    external_reference '12345'
    mercado_pago_id '12345'
  end

  factory :mercado_pago_custom_source, class: Spree::MercadoPagoCustomSource do
    transient do
      state :approved
    end

    before(:build) do |source, evaluator|
      if state == :approved
        card_token 'ff8080814c11e237014c1ff593b57b4d'
        integration_payment_method_id 'visa'
        installments 1
      end
    end
  end
end