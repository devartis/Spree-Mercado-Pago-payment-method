class RenamePaymentMethodType < ActiveRecord::Migration
  def change
    Spree::PaymentMethod.where(type: 'PaymentMethod::MercadoPago').update_all(type: 'Spree::PaymentMethod::MercadoPagoBasic')
    Spree::PaymentMethod.where(type: 'PaymentMethod::MercadoPagoManual').update_all(type: 'Spree::PaymentMethod::MercadoPagoManual')
    Spree::PaymentMethod.where(type: 'PaymentMethod::MercadoPagoCustom').update_all(type: 'Spree::PaymentMethod::MercadoPagoCustom')

    Spree::Payment.where(source_type: 'MercadoPagoManualSource').update_all(source_type: 'Spree::MercadoPagoManualSource')
  end
end
