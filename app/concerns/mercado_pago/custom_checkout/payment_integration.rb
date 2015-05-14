module MercadoPago
  module CustomCheckout
    module PaymentIntegration
      extend ActiveSupport::Concern

      def payment_source_class
        ::MercadoPago::CustomCheckout::Source
      end

      def provider_source_class
        ::MercadoPago::CustomCheckout::Client
      end

    end
  end
end