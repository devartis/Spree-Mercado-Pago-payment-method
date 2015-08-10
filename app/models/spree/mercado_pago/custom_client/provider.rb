module Spree
  module MercadoPago
    module CustomClient
      class Provider
        attr_reader :public_key, :access_token, :client

        def initialize(access_token, public_key)
          @public_key = public_key
          @access_token = access_token
          @client = ::MercadoPago.new(self.access_token)
        end

        def payments
          CustomClient::Payment.new(self.client, self.public_key)
        end

        def customers
          CustomClient::Customer.new(self.client, self.public_key)
        end

        def payment_methods
          CustomClient::PaymentMethod.new(self.client, self.public_key)
        end
      end
    end
  end
end