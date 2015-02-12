# -*- encoding : utf-8 -*-
require 'rest_client'
require 'mercado_pago/client/authentication'
require 'mercado_pago/client/preferences'
require 'mercado_pago/client/api'

module MercadoPago

  class Client
    # These three includes are because of the user of line_item_description from ProductsHelper

    include Authentication
    include Preferences
    include API

    attr_reader :errors
    attr_reader :auth_response
    attr_reader :preferences_response

    def initialize(payment_method, options={})
      @payment_method = payment_method
      @api_options = options.clone
      @errors = []
    end

    def get_external_reference(mercado_pago_id)
      response = send_notification_request mercado_pago_id
      if response
        response['collection']['external_reference']
      end
    end

    def get_payment_status(external_reference)
      response = send_search_request({:external_reference => external_reference, :access_token => access_token})

      if response['results'].empty?
        "pending"
      else
        response['results'][0]['collection']['status']
      end
    end

    # Returns any of these status: 'pending', 'accepted', 'rejected', 'cancelled'
    def get_money_request_status(mercado_pago_id)
      response = send_search_money_request(mercado_pago_id)
      response['status'] if response
    end

    def create_money_request(payer_email, amount, description)
      send_create_money_request(payer_email, amount, description)
    end

    private

    def log_error(msg, response, request, result)
      Rails.logger.info msg
      Rails.logger.info "response: #{response}."
      Rails.logger.info "request args: #{request.args}."
      Rails.logger.info "result #{result}."
    end

    def send_notification_request(mercado_pago_id)
      url = create_url(notifications_url(mercado_pago_id), access_token: access_token)
      options = {:content_type => 'application/x-www-form-urlencoded', :accept => 'application/json'}
      get(url, options, quiet: true)
    end

    def send_search_request(params, options={})
      url = create_url(search_url, params)
      options = {:content_type => 'application/x-www-form-urlencoded', :accept => 'application/json'}
      get(url, options)
    end

    # https://developers.mercadopago.com/documentacion/solicitar-dinero#!/post
    # Should return a json with this format
    # {
    #     "id": 1234567,
    #     "status": "pending",
    #     "site_id": "Sitio del pago",
    #     "currency_id": "Tipo de moneda",
    #     "amount": 2.1,
    #     "collector_id": tu_identificador_como_vendedor,
    #     "collector_email": "collector@email.com",
    #     "payer_id": identificador_de_tu_comprador,
    #     "payer_email": "payer@email.com",
    #     "description": "Descripción",
    #     "concept_type": "off_platform",
    #     "init_point": "URL-de-acceso-al-checkout",
    #     "external_reference": "Reference_1234",
    #     "pref_id": "identificador_de_la_preferencia",
    #     "date_created": "2014-04-24T16:37:22.032-04:00",
    #     "last_updated": "2014-04-24T16:37:22.032-04:00"
    # }
    def send_create_money_request(payer_email, amount, description)
      url = create_url(money_request_url, access_token: access_token)
      headers = {:content_type => 'application/json', :accept => 'application/json'}
      params = {
          currency_id: 'ARS',
          payer_email: payer_email,
          amount: amount,
          description: description,
          concept_type: 'off_platform'
      }
      post url, params, headers
    end

    # https://developers.mercadopago.com/documentacion/solicitar-dinero#!/get
    # Should return a json just like send_create_money_request
    def send_search_money_request(mercado_pago_id)
      url = create_url(money_request_url(mercado_pago_id), access_token: access_token)
      headers = { :accept => 'application/json' }
      get url, headers, quiet: true
    end
  end
end