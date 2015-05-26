module Spree
  module MercadoPago
    module Provider
      extend ActiveSupport::Concern

      def provider_class
        ::Spree::MercadoPago::Client
      end

      def provider(additional_options={})
        options = respond_to?(:default_options) ? default_options : {}
        client = provider_class.new(self, options.merge(additional_options))
        client.authenticate
        client
      end
    end
  end
end