# == Schema Information
#
# Table name: spree_mercado_pago_custom_sources
#
#  id                               :integer          not null, primary key
#  card_token                       :string(255)
#  integration_payment_method_id    :string(255)
#  installments                     :integer
#  document_type                    :integer          default(0)
#  document_number                  :integer


module Spree
  class MercadoPagoCustomSource < ActiveRecord::Base
    enum document_type: {dni: 1, ci: 2, le: 3, lc: 4}
    belongs_to :payment_method
    belongs_to :user
    has_many :payments, as: :source, class_name: '::Spree::Payment'

    def save_response_error(response)
      cause = response[:cause].first
      self.update!(error_code: cause[:code], failure_message: cause[:description])
    end
  end
end