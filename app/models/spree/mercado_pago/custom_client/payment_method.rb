class Spree::MercadoPago::CustomClient::PaymentMethod < Spree::MercadoPago::CustomClient::Resource
  def installment_plans(payment_method_id, amount)
    do_get payment_method_installment_plans_endpoint, {
                                                        payment_method_id: payment_method_id,
                                                        amount: amount,
                                                        public_key: self.public_key
                                                    }
  end

  private

  def payment_method_installment_plans_endpoint
    "#{self.endpoint}/installments"
  end
end