class AddMercadoPagoPaymentIdToSpreeMercadoPagoCustomSources < ActiveRecord::Migration
  def change
    add_column :spree_mercado_pago_custom_sources, :external_reference, :string
    add_column :spree_mercado_pago_custom_sources, :mercado_pago_id, :integer
  end
end
