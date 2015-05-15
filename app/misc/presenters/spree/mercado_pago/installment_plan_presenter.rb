class Spree::MercadoPago::InstallmentPlanPresenter
  attr_accessor :installments, :discount_percentage, :interest_percentage, :order
  attr_accessor :id, :financial_corporation_id, :credit_card_type_id, :description #Added in order to render the object

  def initialize(installment_plan)
    @installments = installment_plan[:installments].to_i
    @discount_percentage = installment_plan[:disccount_rate].to_f
    @interest_percentage = installment_plan[:installment_rate].to_f
    @order = SpreeDecidir::InstallmentPlanOrderCalculator.new(interest_percentage, discount_percentage, installments)
  end
end
