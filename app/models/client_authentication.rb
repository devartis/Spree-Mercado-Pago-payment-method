class SpreeMercadoPagoClient
  module Authentication
    def authenticate
      response = send_authentication_request
      @auth_response = ActiveSupport::JSON.decode(response)
    rescue RestClient::Exception => e
      @errors << I18n.t(:mp_authentication_error)
      raise MercadoPagoException.new e.message
    end


  private

    def send_authentication_request
      RestClient.post(
        'https://api.mercadolibre.com/oauth/token',
          {:grant_type => 'client_credentials', :client_id => client_id, :client_secret => client_secret},
          :content_type => 'application/x-www-form-urlencoded', :accept => 'application/json'
      )
    end
    
    def client_id
      @payment_method.preferred_client_id
    end

    def client_secret
      @payment_method.preferred_client_secret
    end

  end
end