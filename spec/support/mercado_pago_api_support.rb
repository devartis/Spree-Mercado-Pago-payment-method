module MercadoPagoApiSupport
  def mock_authenticate(client_id, client_secret)
    stub_request(:post, 'https://api.mercadolibre.com/oauth/token').
        with(:body => {'client_id' => client_id, 'client_secret' => client_secret, 'grant_type' => "client_credentials"},
             :headers => {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Length' => '63', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby'}).
        to_return(:status => 200, :body => authenticated_json, :headers => {})
  end

  def mock_get_money_request(money_request_id, response = nil)
    response ||= money_request_json
    access_token = authenticated_json['access_token']
    stub_request(:get, "https://api.mercadolibre.com/money_requests/#{money_request_id}?access_token=#{access_token}").
        with(:headers => {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby'}).
        to_return(:status => 200, :body => money_request_json, :headers => {})
  end

  def money_request_json(status = nil)
    money_request = open_fixture('money_request.json')
    money_request[:status] = status if status
    money_request
  end

  private

  def open_fixture(file_name)
    JSON.parse(File.open("#{::Rails.root.to_s}/../fixtures/#{file_name}", 'r').read, symbolize_names: true)
  end

  def authenticated_json
    open_fixture('authenticated.json')
  end
end