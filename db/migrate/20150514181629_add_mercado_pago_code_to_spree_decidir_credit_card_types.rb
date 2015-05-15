class AddMercadoPagoCodeToSpreeDecidirCreditCardTypes < ActiveRecord::Migration
  def change
    add_column :spree_decidir_credit_card_types, :mercado_pago_code, :string
    
    klass = SpreeDecidir::CreditCardType

    klass.create! name: 'Nativa Mastercard', decidir_code: 15, mercado_pago_code: 'nativa', code: 'NT'
    klass.find(1).update!(mercado_pago_code: 'visa')
    klass.find(2).update!(mercado_pago_code: 'amex')
    klass.find(4).update!(mercado_pago_code: 'mastercard')
    klass.find(21).update!(mercado_pago_code: 'argencard')
    klass.find(9).update!(mercado_pago_code: 'cabal')
    klass.find(3).update!(mercado_pago_code: 'diners')
    klass.find(6).update!(mercado_pago_code: 'naranja')
    klass.find(5).update!(mercado_pago_code: 'tarshop')
    klass.find(7).update!(mercado_pago_code: 'pagofacil')
    klass.find(8).update!(mercado_pago_code: 'rapipago')
  end
end
