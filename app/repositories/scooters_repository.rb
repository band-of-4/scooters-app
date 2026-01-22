class ScootersRepository
  def initialize
    @storage = Strategies::Composite::ScootersStorage.new
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
    if default_storage.is_a?(Strategies::ActiveRecord::ScootersStorage)
      Scooter.new(attrs)
    else
      Strategies::Json::Scooter.new(attrs.merge(id: nil))
    end
  end


  private

  def default_storage
    if database_available?
      Strategies::ActiveRecord::ScootersStorage.new
    else
      Strategies::Json::ScootersStorage.new
    end
  end

  def database_available?
    ActiveRecord::Base.connection.active?
  rescue
    false
  end
end
