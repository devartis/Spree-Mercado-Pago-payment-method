class Spree::MercadoPago::FinancialCorporationPresenter
  extend Forwardable
  attr_accessor :id, :name, :code, :installment_plans, :best_plan

  def initialize(financial_corporation)
    @id = nil
    @code = nil
    @name = financial_corporation[:name]
    @installment_plans = financial_corporation[:installment_plans].collect do |installment_plan|
      Spree::MercadoPago::InstallmentPlanPresenter.new installment_plan
    end
    @best_plan = @installment_plans.min_by { |ip| ip.order }
  end
end