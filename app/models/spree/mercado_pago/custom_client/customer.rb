class Spree::MercadoPago::CustomClient::Customer < Spree::MercadoPago::CustomClient::Resource
  def build_create_params(customer_email)
    {email: customer_email}
  end

  def find_or_create(customer_email)
    response = create(customer_email)
    if response and response[:error] and response[:cause].first[:code].to_i == 101
      saved_customer_response = do_get search_endpoint, params
      saved_customer_response[:id]
    else
      response[:id]
    end
  end

  def associate_card(customer_id, token)
    do_post customer_cards_endpoint(customer_id), {token: token}
  end

  def get_cards(customer_id)
    do_get customer_cards_endpoint(customer_id)
  end

  private

  def customer_cards_endpoint(customer_id)
    "#{self.endpoint(customer_id)}/cards"
  end

  def search_endpoint
    "#{self.endpoint}/search"
  end
end