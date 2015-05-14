class Spree::MercadoPago::CustomClient::Resource
  attr_accessor :client, :version

  def initialize(client, version = 'v1')
    @client = client
    @version = version
  end

  def endpoint
    "/#{version}/#{self.class.name.demodulize.downcase.pluralize}"
  end

  def get(*args)
    client.get(endpoint, build_get_params(*args))
  end

  def create(*args)
    client.post(endpoint, build_create_params(*args))
  end

  def update(*args)
    client.put(endpoint, build_update_params(*args))
  end

  def delete(*args)
    client.delete(endpoint, build_delete_params(*args))
  end
end