# == Schema Information
#
# Table name: spree_mercado_pago_custom_sources
#
#  id                               :integer          not null, primary key
#  card_token                       :string(255)
#  integration_payment_method_id    :string(255)
#  installments                     :integer


module Spree
  class MercadoPagoCustomSource < ActiveRecord::Base
    belongs_to :payment_method
    belongs_to :user
    has_many :payments, as: :source, class_name: '::Spree::Payment'
  end
end