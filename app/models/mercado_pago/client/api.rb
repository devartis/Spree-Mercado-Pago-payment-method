class MercadoPago::Client
  module API

    def sandbox
      @api_options[:sandbox]
    end

    private

    def notifications_url(mercado_pago_id)
      sandbox_part = sandbox ? 'sandbox/' : ''
      "https://api.mercadolibre.com/#{sandbox_part}collections/notifications/#{mercado_pago_id}"
    end

    def search_url
      sandbox_part = sandbox ? 'sandbox/' : ''
      "https://api.mercadolibre.com/#{sandbox_part}collections/search"
    end

    def money_request_url(mercado_pago_id = nil)
      default_url = "https://api.mercadolibre.com/money_requests"
      mercado_pago_id ? "#{default_url}/#{mercado_pago_id}" : default_url
    end

    def create_url(url, params={})
      uri = URI(url)
      uri.query = URI.encode_www_form(params)
      uri.to_s
    end

    def preferences_url(token)
      create_url 'https://api.mercadolibre.com/checkout/preferences', access_token: token
    end

    def get(url, request_options={}, options={})
      response = RestClient.get(url, request_options)
      ActiveSupport::JSON.decode(response)
    rescue => e
      raise e unless options[:quiet]
    end

    def post(url, params={}, headers={}, options={})
      params = params.to_json if ['application/json', :json].include? headers[:content_type]
      response = RestClient.post url, params, headers
      ActiveSupport::JSON.decode(response)
    rescue => e
      raise e unless options[:quiet]
    end
  end
end