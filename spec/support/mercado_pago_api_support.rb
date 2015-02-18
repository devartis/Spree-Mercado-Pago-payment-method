module MercadoPagoApiSupport
  def mock_authenticate(client_id, client_secret)
    headers = default_api_headers.merge({'Content-Length' => '63', 'Content-Type' => 'application/x-www-form-urlencoded'})
    mock_api_call mercado_pago_api_url, '/oauth/token',
                  headers: headers,
                  method: :post,
                  body: {'client_id' => client_id, 'client_secret' => client_secret, 'grant_type' => "client_credentials"},
                  return_body: authenticated_json
  end

  def mock_get_money_request(money_request_id, response = nil)
    response ||= money_request_json
    access_token = JSON.parse(authenticated_json, symbolize_names: true)[:access_token]
    mock_api_call mercado_pago_api_url, "/money_requests/#{money_request_id}?access_token=#{access_token}",
                  return_body: money_request_json
  end

  def mock_get_payment_status(status = 'pending')
    mock_api_call mercado_pago_api_url, '/collections/search', return_body: status
  end

  def money_request_json(status = nil)
    money_request = open_fixture('money_request.json')
    money_request[:status] = status if status
    money_request
  end

  private

  def mock_api_call(host, path, options={})
    headers = options[:headers] || default_api_headers
    return_headers = options[:return_headers] || default_return_headers
    status = options[:status] || default_status_code
    return_body = options[:return_body] || ''
    method = options[:method] || :get
    body = options[:body] || ''

    stub_request(method, "#{host}#{path}").
        with(headers: headers, body: body).
        to_return(status: status, body: return_body, headers: return_headers)
  end

  def open_fixture(file_name)
    File.open("#{::Rails.root.to_s}/../fixtures/#{file_name}", 'r').read
  end

  def authenticated_json
    open_fixture('authenticated.json')
  end

  def mercado_pago_api_url
    'https://api.mercadolibre.com'
  end

  def default_api_headers
    {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'}
  end

  def default_status_code
    200
  end

  def default_return_headers
    {}
  end

end