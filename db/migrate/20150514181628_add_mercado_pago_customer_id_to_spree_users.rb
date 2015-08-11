class AddMercadoPagoCustomerIdToSpreeUsers < ActiveRecord::Migration
  def change
    add_column :spree_users, :mercado_pago_customer_id, :string
  end
end
