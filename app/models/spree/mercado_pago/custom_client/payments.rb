class Spree::MercadoPago::CustomClient::Payments < Spree::MercadoPago::CustomClient::Resource
  def build_create_params(amount, card_token, description, installments, payment_method_id, payer_email)
    {
        transaction_amount: amount,
        token: card_token,
        description: description,
        installments: installments,
        payment_method_id: payment_method_id,
        payer: [{
                    email: payer_email
                }]
    }
  end
end