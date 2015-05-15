class Spree::MercadoPago::CustomClient::Customer < Spree::MercadoPago::CustomClient::Resource
  def build_create_params(customer_email)
    {email: customer_email}
  end

  def associate_card(customer_id, token)
    HashWithIndifferentAccess.new client.post(customer_cards_endpoint(customer_id), {token: token})
  end

  def get_cards(customer_id)
    HashWithIndifferentAccess.new client.get(customer_cards_endpoint(customer_id))
  end

  private

  def customer_cards_endpoint(customer_id)
    "#{self.endpoint(customer_id)}/cards"
  end
end