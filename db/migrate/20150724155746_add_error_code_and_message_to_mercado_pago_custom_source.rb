class AddErrorCodeAndMessageToMercadoPagoCustomSource < ActiveRecord::Migration
  def change
    add_column :spree_mercado_pago_custom_sources, :error_code, :integer
    add_column :spree_mercado_pago_custom_sources, :failure_message, :string
  end
end
