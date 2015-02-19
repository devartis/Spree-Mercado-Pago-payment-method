module MercadoPagoApiSupport
  def mock_authenticate(client_id, client_secret)
    headers = default_api_headers.merge({'Content-Length' => '63', 'Content-Type' => 'application/x-www-form-urlencoded'})
    mock_api_call mercado_pago_api_url, '/oauth/token',
                  headers: headers,
                  method: :post,
                  body: {'client_id' => client_id, 'client_secret' => client_secret, 'grant_type' => "client_credentials"},
                  return_body: authenticated_json
  end

  def mock_get_money_request(money_request_id, status = nil)
    response = money_request_json(status)
    mock_api_call mercado_pago_api_url, "/money_requests/#{money_request_id}?access_token=#{access_token}",
                  return_body: response
  end

  def mock_get_payment_status(external_reference, status = 'pending')
    return_body = { results: [{ collection: { status: status } }] }.to_json.to_s
    mock_api_call mercado_pago_api_url, "/collections/search?access_token=#{access_token}&external_reference=#{external_reference}",
                  return_body: return_body,
                  headers: {'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}
  end

  def money_request_json(status = nil)
    money_request = open_fixture('money_request.json')
    if status
      money_request = JSON.parse(money_request, symbolize_names: true)
      money_request[:status] = status
    end
    money_request.to_json
  end

  private

  def access_token
    JSON.parse(authenticated_json, symbolize_names: true)[:access_token]
  end

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