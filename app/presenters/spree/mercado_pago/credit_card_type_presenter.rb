module Spree
  module MercadoPago
    class CreditCardTypePresenter
      extend Forwardable
      attr_accessor :name, :code, :mp_code, :financial_corporations, :credit_card_type
      attr_accessor :has_installment_plans

      def initialize(api_response, has_installment_plans = false)
        @has_installment_plans = has_installment_plans

        if has_installment_plans
          @mp_code = api_response.first
          financial_corporations = api_response.last
        else
          @mp_code = api_response[:id]
          financial_corporations = nil
        end

        @credit_card_type = get_credit_card_type(@mp_code)

        if @credit_card_type
          @id = @credit_card_type.id
          @code = @credit_card_type.code
          @name = @credit_card_type.name
          @financial_corporations = present_financial_corporations(financial_corporations)
        else
          @financial_corporations = []
        end

      end

      private

      def get_mercado_pago_code(mp_credit_card_type)
        unless has_installment_plans
          mp_credit_card_type[:id]
        else
          mp_credit_card_type[:payment_method_id]
        end
      end

      def get_credit_card_type(mp_code)
        SpreeDecidir::CreditCardType.find_by(mercado_pago_code: mp_code)
      end

      def present_financial_corporations(financial_corporations = nil)
        if @has_installment_plans
          financial_corporations.map do |cct|
            obj = cct[:issuer]
            obj[:installment_plans] = cct[:payer_costs]
            obj
          end.collect do |financial_corporation|
            Spree::MercadoPago::FinancialCorporationPresenter.new(financial_corporation)
          end
        else
          []
        end
      end
    end
  end
end
