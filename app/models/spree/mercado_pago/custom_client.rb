require 'mercadopago'

module Spree
  module MercadoPago
    class CustomClient
      attr_reader :client

      def initialize(access_token)
        @client = ::MercadoPago.new(access_token)
      end

    end
  end
end
