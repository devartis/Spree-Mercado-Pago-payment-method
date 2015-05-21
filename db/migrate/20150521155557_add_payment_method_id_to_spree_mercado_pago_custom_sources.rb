class AddPaymentMethodIdToSpreeMercadoPagoCustomSources < ActiveRecord::Migration
  def change
    add_column :spree_mercado_pago_custom_sources, :payment_method_id, :integer
  end
end
