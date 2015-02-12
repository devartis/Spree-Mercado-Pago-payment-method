# == Schema Information
#
# Table name: mercado_pago_sources
#
#  id                :integer          not null, primary key
#  created_at        :datetime
#  updated_at        :datetime
#  payment_method_id :integer
#  user_id           :integer
#

class MercadoPagoSource < ActiveRecord::Base
  belongs_to :payment_method
  has_many :payments, as: :source, class_name: '::Spree::Payment'
end