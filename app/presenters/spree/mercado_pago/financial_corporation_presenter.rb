module Spree
  module MercadoPago
    class FinancialCorporationPresenter
      extend Forwardable
      attr_accessor :id, :name, :code, :image, :installment_plans, :best_plan

      def initialize(financial_corporation)
        @id = ''
        @code = ''
        @image = financial_corporation[:secure_thumbnail]
        @name = financial_corporation[:name]
        @installment_plans = financial_corporation[:installment_plans].collect do |ip|
          SpreeDecidir::InstallmentPlan.new discount_percentage: ip[:disccount_rate].to_f, interest_percentage: ip[:installment_rate].to_f, installments: ip[:installments]
        end
        @best_plan = @installment_plans.min_by { |ip| ip.order }
      end
    end
  end
end
