module MercadoPagoApiSupport
  def mock_authenticate(client_id, client_secret)
    stub_request(:post, 'https://api.mercadolibre.com/oauth/token').
        with(:body => {"client_id" => client_id, "client_secret" => client_secret, "grant_type" => "client_credentials"},
             :headers => {'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'Content-Length' => '63', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby'}).
        to_return(:status => 200, :body => authenticated_json, :headers => {})
  end

  private

  def authenticated_json
    File.open("#{::Rails.root.to_s}/../fixtures/authenticated.json", 'r').read
  end
end