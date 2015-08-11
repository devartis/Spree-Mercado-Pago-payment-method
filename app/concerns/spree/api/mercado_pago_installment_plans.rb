module Spree
  module Api
    module MercadoPagoInstallmentPlans
      extend ActiveSupport::Concern

      def present_credit_card_types(payment_methods, options = {})
        active_credit_cards = payment_methods.reject do |payment_method|
          payment_method[:status] != 'active' or payment_method[:payment_type_id] != 'credit_card'
        end

        payment_method = options[:payment_method]

        active_credit_cards.collect do |credit_card|
          if payment_method and payment_method[:id]== credit_card[:id]
            ::Spree::MercadoPago::CreditCardTypePresenter.new(credit_card, payment_method[:financial_corporations])
          else
            ::Spree::MercadoPago::CreditCardTypePresenter.new(credit_card)
          end
        end
      end
    end
  end
end