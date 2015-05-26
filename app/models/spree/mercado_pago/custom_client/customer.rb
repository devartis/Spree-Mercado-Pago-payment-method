class Spree::MercadoPago::CustomClient::Customer < Spree::MercadoPago::CustomClient::Resource
  CUSTOMER_ALREADY_EXISTS_CODE = 101

  def build_create_params(customer_email)
    {email: customer_email}
  end

  def find_or_create(customer_email)
    response = create(customer_email)
    if response and response[:cause] and response[:cause].first[:code].to_i == CUSTOMER_ALREADY_EXISTS_CODE
      saved_customer_response = search(customer_email)
      saved_customer_response[:id]
    else
      response[:id]
    end
  end

  def associate_card(customer_id, token)
    response = do_post customer_cards_endpoint(customer_id), {token: token}
    !response[:id].nil?
  end

  def get_cards(customer_id)
    do_get customer_cards_endpoint(customer_id)
  end

  private

  def search(customer_email)
    do_get(search_endpoint, build_create_params(customer_email))[:results].first
  end

  def customer_cards_endpoint(customer_id)
    "#{self.endpoint(customer_id)}/cards"
  end

  def search_endpoint
    "#{self.endpoint}/search"
  end
end