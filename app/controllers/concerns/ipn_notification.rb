module Concerns
  module IpnNotification
    extend ActiveSupport::Concern

    included do
      skip_before_filter :verify_authenticity_token, only: :notification
    end

    def notification
      external_reference = simple_provider.get_external_reference operation_number

      if external_reference
        payment = payment_by external_reference
        if payment
          enqueue_verification payment
        else
          log_no_payment external_reference, operation_number
        end
      else
        log_no_external_reference operation_number
      end

      render status: :ok, nothing: true
    end

    private

    def operation_number
      params[:id]
    end

    def log_no_external_reference(operation_id)
      Rails.logger.warn "Cant not find external reference for operation number: #{operation_id}"
    end

    def log_no_payment(external_reference, operation_id)
      Rails.logger.warn "Cant not find payment identifier: #{external_reference} for operation number: #{operation_id}"
    end

    def enqueue_verification(payment)
      Resque.enqueue(PaymentStatusVerifier, payment.identifier)
    end

    def payment_by(payment_identifier)
      @current_payment ||= Spree::Payment.find_by identifier: payment_identifier
    end

    def simple_provider
      @provider ||= provider_payment_method.provider
    end

    def provider_payment_method
      # FIXME: This is not the best way. What happens with multiples MercadoPago payments?
      @payment_method ||= ::PaymentMethod::MercadoPago.first
    end

  end
end