class CreateSpreeMercadoPagoCustomSource < ActiveRecord::Migration
  def change
    create_table :spree_mercado_pago_custom_sources do |t|
      t.string :card_token
      t.string :integration_payment_method_id
      t.integer :installments
    end
  end
end
