module Spree
  module MercadoPago
    module CustomClient
      class Resource
        attr_accessor :client, :version

        def initialize(client, version = 'v1')
          @client = client
          @version = version
        end

        def endpoint
          "/#{version}/#{self.class.name.downcase}"
        end

        def get(params)
          client.get(endpoint, params)
        end

        def create(params)
          client.post(endpoint, params)
        end

        def update(params)
          client.put(endpoint, params)
        end

        def delete(params)
          client.delete(endpoint, params)
        end
      end

      class Payments < Resource

      end
    end
  end
end