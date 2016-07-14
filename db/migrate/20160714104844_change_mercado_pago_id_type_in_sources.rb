class ChangeMercadoPagoIdTypeInSources < ActiveRecord::Migration
  def change
    change_column :mercado_pago_manual_sources, :mercado_pago_id, :bigint, limit: 8
    change_column :spree_mercado_pago_custom_sources, :mercado_pago_id, :bigint, limit: 8
  end
end
