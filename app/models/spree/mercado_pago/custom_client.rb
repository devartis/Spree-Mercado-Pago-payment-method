require 'mercadopago'

module Spree
  module MercadoPago
    class CustomClient
      attr_reader :client

      def initialize(access_token)
        @client = ::MercadoPago.new(access_token)
      end

      def payments
        CustomClient::Payment.new(self.client)
      end
    end
  end
end
