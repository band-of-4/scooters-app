require Rails.root.join('app', 'exceptions', 'scooter_rental_error')

class DatabaseStorage
  
  def all(model_class)
    model_class.all.map(&:attributes).map(&:symbolize_keys)
  end
  
  def find(model_class, id)
    record = model_class.find_by(id: id)
    raise SRRecordNotFound, "#{model_class.name} with id=#{id} not found" unless record
    record.attributes.symbolize_keys
  end
  
  def find_by(model_class, conditions)
    record = model_class.find_by(conditions)
    record&.attributes&.symbolize_keys
  end
  
  def where(model_class, conditions)
    model_class.where(conditions).map(&:attributes).map(&:symbolize_keys)
  end
  
  def create(model_class, attributes)
    record = model_class.create!(attributes)
    record.attributes.symbolize_keys
  end
  
  def update(model_class, id, attributes)
    record = model_class.find(id)
    record.update!(attributes)
    record.attributes.symbolize_keys
  end
  
  def destroy(model_class, id)
    record = model_class.find(id)
    record_data = record.attributes.symbolize_keys
    record.destroy!
    record_data
  end
  
  def count(model_class)
    model_class.count
  end
  
  def save_all(full_data)
    # Не реализовано для БД
    raise NotImplementedError, "save_all not available for database storage"
  end
  
  def full_data
    {
      clients: all(Client),
      scooters: all(Scooter),
      rentals: all(Rental)
    }
  end
  
  def clear!
    # Не реализовано для БД (опасно!)
    raise NotImplementedError, "clear! not available for database storage"
  end
end