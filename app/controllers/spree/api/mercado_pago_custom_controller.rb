module Spree
  module Api
    class MercadoPagoCustomController < BaseController
      before_filter :find_order, only: :installment_plans

      def installment_plans
        payment_method = Spree::PaymentMethod::MercadoPagoCustom.find params[:payment_method_id]
        mp_payment_method_id = params[:mp_payment_method_id]
        amount = @order.total_without_payment_adjustments
        if mp_payment_method_id
          credit_card_types_api_response = payment_method.provider.payment_methods.installment_plans(mp_payment_method_id, amount)
          @credit_card_types = present_credit_card_types(credit_card_types_api_response, true)
        else
          credit_card_types_api_response = payment_method.provider.payment_methods.get
          @credit_card_types = present_credit_card_types(credit_card_types_api_response, false)
        end
      end

      def present_credit_card_types(api_response, has_installment_plans = false)
        api_response = api_response[:response]

        if has_installment_plans
          api_response = api_response.group_by { |cct| cct[:payment_method_id] }
        else
          api_response = api_response.reject { |cct| cct[:status] != 'active' }
        end
        api_response.collect do |cct|
          Spree::MercadoPago::CreditCardTypePresenter.new(cct, has_installment_plans)
        end
      end

      private

      def find_order
        @order = Spree::Order.find_by!(number: params[:id])
      end

    end
  end
end