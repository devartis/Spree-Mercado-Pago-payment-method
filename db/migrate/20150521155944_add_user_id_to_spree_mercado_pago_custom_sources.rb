class AddUserIdToSpreeMercadoPagoCustomSources < ActiveRecord::Migration
  def change
    add_column :spree_mercado_pago_custom_sources, :user_id, :integer
  end
end
