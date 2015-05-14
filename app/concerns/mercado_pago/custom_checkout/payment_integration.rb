module MercadoPago
  module CustomCheckout
    module PaymentIntegration
      extend ActiveSupport::Concern

      def purchase(amount, source, gateway_options)
      end

      def provider_source_class
        ::MercadoPago::CustomCheckout::Client
      end

      def provider
        provider_class.new self.access_token
      end

    end
  end
end