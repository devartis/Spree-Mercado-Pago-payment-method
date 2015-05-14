module Spree
  class MercadoPagoManualSource < ActiveRecord::Base
    belongs_to :payment_method
    has_many :payments, as: :source, class_name: '::Spree::Payment'
  end
end