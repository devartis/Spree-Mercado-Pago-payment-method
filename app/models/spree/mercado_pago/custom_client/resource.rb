class Spree::MercadoPago::CustomClient::Resource
  attr_accessor :client, :version

  def initialize(client, version = 'v1')
    @client = client
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
    extract_response client.get(*args)
  end

  def do_delete(*args)
    extract_response client.delete(*args)
  end

  def do_post(*args)
    extract_response client.post(*args)
  end

  def do_put(*args)
    extract_response client.put(*args)
  end

  def extract_response(response)
    HashWithIndifferentAccess.new(response)[:response]
  end

end