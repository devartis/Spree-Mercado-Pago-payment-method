module Spree
  module Api
    class MercadoPagoCustomController < BaseController
      before_filter :find_order, only: :installment_plans
      before_filter :find_payment_method, only: [:installment_plans, :cards]

      def installment_plans
        mp_payment_method_id = params[:mp_payment_method_id]
        @amount = @order.total_without_payment_adjustments
        if mp_payment_method_id
          credit_card_types_api_response = @payment_method.provider.payment_methods.installment_plans(mp_payment_method_id, @amount)
          @credit_card_types = present_credit_card_types(credit_card_types_api_response, true)
        else
          credit_card_types_api_response = @payment_method.provider.payment_methods.get
          @credit_card_types = present_credit_card_types(credit_card_types_api_response, false)
        end

        render 'spree/api/credit_card_types/index'
      end

      def cards
        mercado_pago_customer_id = current_api_user.mercado_pago_customer_id
        cards = @payment_method.provider.customers.get_cards(mercado_pago_customer_id)
        if cards.is_a?(Array)
          render json: {count: cards.count, cards: cards}
        else
          render json: {count: 0, cards: []}
        end
      end

      private

      def find_order
        @order = Spree::Order.find_by!(number: params[:id])
      end

      def find_payment_method
        @payment_method = Spree::PaymentMethod::MercadoPagoCustom.find params[:payment_method_id]
      end

      def present_credit_card_types(api_response, has_installment_plans = false)
        api_response = api_response

        if has_installment_plans
          api_response = api_response.group_by { |cct| cct[:payment_method_id] }
        else
          api_response = api_response.reject { |cct| cct[:status] != 'active' }
        end
        api_response.collect do |cct|
          Spree::MercadoPago::CreditCardTypePresenter.new(cct, has_installment_plans)
        end.reject do |cct|
          cct.credit_card_type.nil?
        end
      end

    end
  end
end