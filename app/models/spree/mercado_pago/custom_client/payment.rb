class Spree::MercadoPago::CustomClient::Payment < Spree::MercadoPago::CustomClient::Resource
  def build_create_params(amount, card_token, description, installments, options={})
    if options.keys.size == 2 and options[:payment_method_id] and options[:payer_email]
      diff_params = {
          payment_method_id: options[:payment_method_id],
          payer: [
              {email: options[:payer_email]}
          ]
      }
    elsif options.keys.size == 1 and options[:payer_id]
      diff_params = {
          payer: [
              {id: options[:payer_id]}
          ]
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