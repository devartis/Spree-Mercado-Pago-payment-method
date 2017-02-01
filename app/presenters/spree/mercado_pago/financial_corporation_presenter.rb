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

          costs_label = ip[:labels].map(&:downcase).find{ |label| label.include?('cft') && label.include?('tea') }
          cft = parse_label(costs_label, 'cft', 0)
          tea = parse_label(costs_label, 'tea', 1)

          SpreeDecidir::InstallmentPlan.new(discount_percentage: ip[:disccount_rate].to_f,
                                            interest_percentage: ip[:installment_rate].to_f,
                                            installments: ip[:installments], cft: cft, tea: tea)
        end
        @best_plan = @installment_plans.min_by { |ip| ip.order }
      end

      def parse_label(label, attr, position)
        label_value = 0  # default value
        label_with_attr = label.split('|')[position] if label.present?
        label_number = label_with_attr[/.*\_(.*?)%/,1] if label_with_attr.present? && label_with_attr.include?(attr)
        label_value = label_number.gsub(',','.').to_f if label_number.present?
        label_value
      end
    end
  end
end
