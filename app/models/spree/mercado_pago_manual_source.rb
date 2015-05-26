module Spree
  class MercadoPagoManualSource < ActiveRecord::Base
    belongs_to :payment_method
    has_many :payments, as: :source, class_name: '::Spree::Payment'

    def self.table_name
      'mercado_pago_manual_sources'
    end
  end
end