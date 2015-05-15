class Spree::MercadoPago::FinancialCorporationPresenter
  extend Forwardable
  attr_accessor :id, :name, :code, :installment_plans

  def initialize(financial_corporation)
    @id = nil
    @code = nil
    @name = financial_corporation[:name]
    @installment_plans = financial_corporation[:installment_plans]
  end
end