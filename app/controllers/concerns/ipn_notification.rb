module Concerns
  module IpnNotification
    extend ActiveSupport::Concerns

    included do
      skip_before_filter :verify_authenticity_token, only: :notification
    end

    def notification
      # TODO: FIXME. This is not the best way. What happens with multiples MercadoPago payments?
      @payment_method = ::PaymentMethod::MercadoPago.first
      external_reference = provider.get_external_reference params[:id]

      if external_reference
        payment = current_payment external_reference
        Resque.enqueue(PaymentStatusVerifier, payment.identifier) if payment
      end

      render status: :ok, nothing: true
    end


    private

    def provider
      @provider ||= payment_method.provider({:payer => payer_data})
    end

    def payment_method
      @payment_method ||= ::PaymentMethod::MercadoPago.find (params[:payment_method_id])
    end

  end
end