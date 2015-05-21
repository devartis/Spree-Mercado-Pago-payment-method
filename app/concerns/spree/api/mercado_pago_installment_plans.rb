module Spree
  module Api
    module MercadoPagoInstallmentPlans
      extend ActiveSupport::Concern

      def present_credit_card_types(api_response, has_installment_plans = false)
        api_response = api_response

        if has_installment_plans
          api_response = api_response.group_by { |cct| cct[:payment_method_id] }
        else
          api_response = api_response.reject { |cct| cct[:status] != 'active' }
        end
        api_response.collect do |cct|
          ::Spree::MercadoPago::CreditCardTypePresenter.new(cct, has_installment_plans)
        end.reject do |cct|
          cct.credit_card_type.nil?
        end
      end
    end
  end
end