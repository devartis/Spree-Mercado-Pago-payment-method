class Spree::MercadoPago::CustomClient::Resource
  attr_accessor :client, :version, :public_key

  def initialize(client, public_key, version = 'v1')
    @client = client
    @public_key = public_key
    @version = version
  end

  def endpoint(id = nil)
    endpoint = "/#{version}/#{self.class.name.demodulize.pluralize.underscore}"
    if id 
      endpoint = "#{endpoint}/#{id}"
    end
    endpoint
  end

  def get(id = nil)
    do_get endpoint(id)
  end

  def delete(id)
    do_delete endpoint(id)
  end

  def create(*args)
    do_post endpoint, build_create_params(*args)
  end

  def update(id, *args)
    do_put endpoint(id), build_update_params(*args)
  end

  protected

  def do_get(uri, params = nil, use_access_token = true)
    do_request(:get, uri, params, use_access_token)
  end

  def do_delete(uri, params = nil)
    do_request(:delete, uri, params)
  end

  def do_post(uri, data, params = nil)
    do_request(:post, uri, data, params)
  end

  def do_put(uri, data, params = nil)
    do_request(:put, uri, data, params)
  end

  def do_request(method, *args)
    extract_response client.send(method, *args)
  end

  def extract_response(response)
    HashWithIndifferentAccess.new(response)[:response]
  end

end