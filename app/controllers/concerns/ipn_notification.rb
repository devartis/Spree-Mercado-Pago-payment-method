module Concerns
  module IpnNotification
    extend ActiveSupport::Concern

    included do
      skip_before_filter :authenticate_user, only: :notification
      skip_before_filter :verify_authenticity_token, only: :notification
    end

    def notification
      authorize! :ipn_notification, ::Spree::Order if api_key
      external_reference = provider.get_external_reference operation_number

      if external_reference
        payment = payment_by external_reference
        if payment
          enqueue_verification payment
          decide_render(payment.order.number) && return
        else
          log_no_payment external_reference, operation_number
        end
      else
        log_no_external_reference operation_number
      end

      decide_render nil
    end

    private

    def decide_render(order_number)
      if api_key
        render json: {order_number: order_number}
      else
        render nothing: true
      end
    end

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
      Resque.enqueue(PaymentStatusVerifier, {identifier: payment.identifier})
    end

    def payment_by(payment_identifier)
      @current_payment ||= ::Spree::Payment.find_by identifier: payment_identifier
    end

  end
end