class ClientDecorator
  def initialize(client)
    @client = client
  end

  def method_missing(name, *args, &block)
    @client.public_send(name, *args, &block)
  end

  def respond_to_missing?(name, include_private = false)
    @client.respond_to?(name, include_private)
  end
end
