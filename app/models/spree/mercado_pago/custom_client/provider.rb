module Spree
  module MercadoPago
    module CustomClient
      class Provider
        attr_reader :client

        def initialize(access_token)
          @client = ::MercadoPago.new(access_token)
        end

        def payments
          CustomClient::Payment.new(self.client)
        end

        def customers
          CustomClient::Customer.new(self.client)
        end

        def payment_methods
          CustomClient::PaymentMethod.new(self.client)
        end
      end
    end
  end
end