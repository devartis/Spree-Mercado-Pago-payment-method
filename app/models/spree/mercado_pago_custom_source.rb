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
#  raw_response                     :text
#  state                            :string(255)

module Spree
  class MercadoPagoCustomSource < ActiveRecord::Base
    enum document_type: {dni: 1, ci: 2, le: 3, lc: 4}
    belongs_to :payment_method
    belongs_to :user
    has_many :payments, as: :source, class_name: '::Spree::Payment'

    serialize :raw_response, Hash

    def save_response_error(response)
      if response[:status_detail]
        error_code = response[:status_detail]
      elsif response[:cause]
        cause = response[:cause].first
        error_code = "e#{cause[:code]}"
      else
        error_code = 'default'
      end
      self.update!(error_code: error_code, failure_message: description_for(error_code))
    end

    def approved?
      self.state == 'approved'
    end

    def pending?
      self.state == 'in_process'
    end

    private

    def description_for(error_code)
      begin
        return I18n.t(error_code, scope: 'mp_custom_errors', raise: true)
      rescue I18n::MissingTranslationData
        return I18n.t('default', scope: 'mp_custom_errors')
      end
    end
  end
end