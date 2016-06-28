class AddRawResponseToMercadoPagoCustomSource < ActiveRecord::Migration
  def change
    add_column :spree_mercado_pago_custom_sources, :raw_response, :text
  end
end