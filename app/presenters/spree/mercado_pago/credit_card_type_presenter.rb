module Spree
  module MercadoPago
    class CreditCardTypePresenter
      extend Forwardable
      attr_accessor :id, :name, :code, :mercado_pago_code, :financial_corporations, :credit_card_type

      def initialize(api_response, financial_corporations = [])
        @mercado_pago_code = api_response[:id]

        @credit_card_type = SpreeDecidir::CreditCardType.find_by(mercado_pago_code: @mercado_pago_code)

        if @credit_card_type
          @id = @credit_card_type.id
          @code = @credit_card_type.code
          @name = @credit_card_type.name
        else
          Rails.logger.error("MP Custom Checkout - No CreditCardType with mercado_pago_code \"#{@mercado_pago_code}\" was found.")
        end

        @financial_corporations = present_financial_corporations(financial_corporations)
      end

      def found
        !@id.nil?
      end
      alias_method :found?, :found

      private

      def present_financial_corporations(financial_corporations)
        financial_corporations.collect do |info|
          financial_corporation = info[:issuer]
          financial_corporation[:installment_plans] = info[:payer_costs]
          FinancialCorporationPresenter.new(financial_corporation)
        end
      end
    end
  end
end
