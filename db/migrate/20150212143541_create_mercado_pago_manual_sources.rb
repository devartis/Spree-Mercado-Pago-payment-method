class CreateMercadoPagoManualSources < ActiveRecord::Migration
  def change
    create_table :mercado_pago_manual_sources do |t|
      t.integer :mercado_pago_id
      t.decimal :amount, precision: 10, scale: 2, default: 0.0
      t.string  :payer_email
      t.integer :payer_id
      t.string  :external_reference
      t.string  :pref_id
      t.integer :user_id
      t.integer :payment_method_id

      t.timestamps
    end
  end
end
