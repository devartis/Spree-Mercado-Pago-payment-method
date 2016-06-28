class AddStateToMercadoPagoCustomSource < ActiveRecord::Migration
  def change
    add_column :spree_mercado_pago_custom_sources, :state, :string
  end
end
