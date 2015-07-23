module Spree
  module Api
    class MercadoPagoCustomController < BaseController
      before_filter :find_payment_method, only: [:installment_plans, :cards]
      before_filter :find_order, only: :installment_plans

      include Spree::Api::MercadoPagoInstallmentPlans

      def installment_plans
        mp_payment_method_id = params[:mp_payment_method_id]
        @amount = @order.total_without_payment_adjustments
        mercado_pago_payment_methods = @payment_method.provider.payment_methods.get

        @credit_card_types = if mp_payment_method_id
                               installments_by_financial_corporation = @payment_method.provider.payment_methods.installment_plans(mp_payment_method_id, @amount)
                               present_credit_card_types(mercado_pago_payment_methods,
                                                         payment_method: {id: mp_payment_method_id,
                                                                          financial_corporations: installments_by_financial_corporation})
                             else
                               present_credit_card_types(mercado_pago_payment_methods)
                             end

        @credit_card_types.reject! { |cc| !cc.found? }

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

      private

      def find_order
        @order = Spree::Order.find_by!(number: params[:order_id])
      end

      def find_payment_method
        @payment_method = if params[:payment_method_id]
                            Spree::PaymentMethod::MercadoPagoCustom.active.find params[:payment_method_id]
                          else
                            Spree::PaymentMethod::MercadoPagoCustom.active.first
                          end
      end
    end
  end
end