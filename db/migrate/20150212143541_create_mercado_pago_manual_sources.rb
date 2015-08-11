class CreateMercadoPagoManualSources < ActiveRecord::Migration
  def change
    create_table :mercado_pago_manual_sources do |t|
      t.integer :mercado_pago_id
      t.string  :payer_email
      t.string  :external_reference
      t.integer :user_id
      t.integer :payment_method_id
      t.text :description

      t.timestamps
    end
  end
end
