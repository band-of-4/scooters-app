class ClientsRepository
  def initialize
    @storage = Strategies::Composite::ClientsStorage.new
  end

  def all
    @storage.all
  end

  def find(id)
    @storage.find(id)
  end

  def create(attrs)
    @storage.create(attrs)
  end

  def update(id,attrs)
    @storage.update(id, attrs)
  end

  def destroy(id)
    @storage.destroy(id)
  end

  def build(attrs = {})
    if default_storage.is_a?(Strategies::ActiveRecord::ClientsStorage)
      Client.new(attrs)
    else
      puts 'repository'
      puts attrs
      Strategies::Json::Client.new(attrs.merge(id: nil))
    end
  end


  private

  def default_storage
    if database_available?
      Strategies::ActiveRecord::ClientsStorage.new
    else
      Strategies::Json::ClientsStorage.new
    end
  end

  def database_available?
    ActiveRecord::Base.connection.active?
  rescue
    false
  end
end
