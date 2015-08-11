class Spree::MercadoPago::CustomClient::Payment < Spree::MercadoPago::CustomClient::Resource
  def search(params)
    do_get '/v1/payments/search', params
  end

  def build_create_params(amount, card_token, description, installments, options={})
    diff_params = if options.keys.size == 2 and options[:payment_method_id] and options[:payer_email]
                    {
                        payment_method_id: options[:payment_method_id],
                        payer: {email: options[:payer_email]}
                    }
                  elsif options.keys.size == 1 and options[:payer_id]
                    {
                        payer: {id: options[:payer_id]}
                    }
                  end
    common_params = {
        transaction_amount: amount,
        token: card_token,
        description: description,
        installments: installments,
    }
    common_params.merge(diff_params)
  end
end