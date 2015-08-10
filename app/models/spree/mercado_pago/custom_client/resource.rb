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

  def do_get(*args)
    do_request(:get, *args)
  end

  def do_delete(*args)
    do_request(:delete, *args)
  end

  def do_post(*args)
    do_request(:post, *args)
  end

  def do_put(*args)
    do_request(:put, *args)
  end

  def do_request(method, *args)
    extract_response client.send(method, *args)
  end

  def extract_response(response)
    HashWithIndifferentAccess.new(response)[:response]
  end

end