class Spree::MercadoPago::CustomClient::Resource
  attr_accessor :client, :version

  def initialize(client, version = 'v1')
    @client = client
    @version = version
  end

  def collection_endpoint
    "/#{version}/#{self.class.name.demodulize.downcase.pluralize}"
  end

  def resource_endpoint(id)
    self.collection_endpoint + "/#{id}"
  end

  def get(id)
    client.get(resource_endpoint(id))
  end

  def delete(id)
    client.delete(resource_endpoint(id))
  end

  def create(*args)
    client.post(collection_endpoint, build_create_params(*args))
  end

  def update(id, *args)
    client.put(resource_endpoint(id), build_update_params(*args))
  end

end