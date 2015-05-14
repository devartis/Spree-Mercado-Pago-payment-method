class Spree::MercadoPago::CustomClient::Resource
  attr_accessor :client, :version

  def initialize(client, version = 'v1')
    @client = client
    @version = version
  end

  def endpoint(id = nil)
    endpoint = "/#{version}/#{self.class.name.demodulize.downcase.pluralize}"
    if id 
      endpoint = "#{endpoint}/#{id}"
    end
    endpoint
  end

  def get(id)
    client.get(endpoint(id))
  end

  def delete(id)
    client.delete(endpoint(id))
  end

  def create(*args)
    client.post(endpoint, build_create_params(*args))
  end

  def update(id, *args)
    client.put(endpoint(id), build_update_params(*args))
  end

end