class AddDocumentTypeAndDocumentNumberToMercadoPagoCustomSource < ActiveRecord::Migration
  def change
    add_column :spree_mercado_pago_custom_sources, :document_type, :integer, default: 0
    add_column :spree_mercado_pago_custom_sources, :document_number, :integer
  end
end
