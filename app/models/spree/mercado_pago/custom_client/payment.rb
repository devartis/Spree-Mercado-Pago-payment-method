class Spree::MercadoPago::CustomClient::Payment < Spree::MercadoPago::CustomClient::Resource
  def search(params)
    do_get '/v1/payments/search', params
  end

  def build_create_params(amount, card_token, description, installments, additional_info, payer_options={})
    diff_params = if payer_options.keys.size == 2 and payer_options[:payment_method_id] and payer_options[:payer_email]
                    {
                        payment_method_id: payer_options[:payment_method_id],
                        payer: {email: payer_options[:payer_email]}
                    }
                  elsif payer_options.keys.size == 1 and payer_options[:payer_id]
                    {
                        payer: {id: payer_options[:payer_id]}
                    }
                  end
    common_params = {
        transaction_amount: amount,
        token: card_token,
        description: description,
        installments: installments,
    }
    common_params.merge(diff_params).merge(additional_info)
  end
end