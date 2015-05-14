class RenamePaymentMethodType < ActiveRecord::Migration
  def change
    Spree::PaymentMethod.where(type: 'PaymentMethod::MercadoPago').update_all(type: 'Spree::PaymentMethod::MercadoPago')
    Spree::PaymentMethod.where(type: 'PaymentMethod::MercadoPagoManual').update_all(type: 'Spree::PaymentMethod::MercadoPagoManual')
    Spree::PaymentMethod.where(type: 'PaymentMethod::MercadoPagoCustom').update_all(type: 'Spree::PaymentMethod::MercadoPagoCustom')
  end
end
