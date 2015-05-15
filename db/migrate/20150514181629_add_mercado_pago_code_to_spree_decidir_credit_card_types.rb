class AddMercadoPagoCodeToSpreeDecidirCreditCardTypes < ActiveRecord::Migration
  def change
    add_column :spree_decidir_credit_card_types, :mercado_pago_code, :string

    SpreeDecidir::CreditCardType.create! name: 'Nativa Mastercard', decidir_code: '', mercado_pago_code: 'nativa', code: 'NT'
    SpreeDecidir::CreditCardTypes.find(1).update!(mercado_pago_code: 'visa')
    SpreeDecidir::CreditCardTypes.find(2).update!(mercado_pago_code: 'amex')
    SpreeDecidir::CreditCardTypes.find(4).update!(mercado_pago_code: 'mastercard')
    SpreeDecidir::CreditCardTypes.find(21).update!(mercado_pago_code: 'argencard')
    SpreeDecidir::CreditCardTypes.find(9).update!(mercado_pago_code: 'cabal')
    SpreeDecidir::CreditCardTypes.find(3).update!(mercado_pago_code: 'diners')
    SpreeDecidir::CreditCardTypes.find(6).update!(mercado_pago_code: 'naranja')
    SpreeDecidir::CreditCardTypes.find(5).update!(mercado_pago_code: 'tarshop')
    SpreeDecidir::CreditCardTypes.find(7).update!(mercado_pago_code: 'pagofacil')
    SpreeDecidir::CreditCardTypes.find(8).update!(mercado_pago_code: 'rapipago')
  end
end
