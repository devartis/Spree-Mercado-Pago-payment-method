FactoryGirl.define do
  factory :mp_manual_payment, class: Spree::Payment do
    amount 45.75
    association(:payment_method, factory: :mercado_pago_manual_payment_method)
    association(:source, factory: :mercado_pago_manual_source)
    order
    state 'checkout'
    response_code '12345'
  end
end