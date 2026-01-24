require Rails.root.join('app', 'exceptions', 'scooter_rental_error')

class FileStorage
  attr_reader :filepath, :data
  
  def initialize(filepath = nil)
    @filepath = filepath || Rails.root.join('storage', 'offline', 'offline_data.json')
    @data = load_data
  end
  
  def all(model_class)
    collection_name = model_class.name.underscore.pluralize.to_sym
    data[collection_name] || []
  end
  
  def find(model_class, id)
    records = all(model_class)
    record = records.find { |r| r[:id].to_s == id.to_s }
    raise SRRecordNotFound, "#{model_class.name} with id=#{id} not found" unless record
    record
  end
  
  def find_by(model_class, conditions)
    puts "FileStorage.find_by: #{model_class.name}, conditions: #{conditions.inspect}"
    
    records = all(model_class)
    result = records.find do |record|
        conditions.all? { |key, value| record[key] == value }
    end
    
    puts "FileStorage.find_by result: #{result.inspect}"
    result
    end
  
  def where(model_class, conditions)
    records = all(model_class)
    records.select do |record|
      conditions.all? { |key, value| record[key] == value }
    end
  end
  
  def create(model_class, attributes)
    records = all(model_class)
    
    new_id = generate_id(records)
    record_data = attributes.merge(id: new_id)
    
    records << record_data
    save_collection(model_class, records)
    
    record_data
  end
  
  def update(model_class, id, attributes)
    records = all(model_class)
    index = records.find_index { |r| r[:id].to_s == id.to_s }
    raise SRRecordNotFound, "#{model_class.name} with id=#{id} not found" unless index
    
    records[index] = records[index].merge(attributes)
    save_collection(model_class, records)
    
    records[index]
  end
  
  def destroy(model_class, id)
    records = all(model_class)
    index = records.find_index { |r| r[:id].to_s == id.to_s }
    raise SRRecordNotFound, "#{model_class.name} with id=#{id} not found" unless index
    
    deleted_record = records.delete_at(index)
    save_collection(model_class, records)
    
    deleted_record
  end
  
  def count(model_class)
    all(model_class).count
  end
  
  def save_all(full_data)
    Rails.logger.info "FileStorage.save_all called"
    Rails.logger.info "Data received:"
    Rails.logger.info "  Clients: #{full_data[:clients]&.count || 0}"
    Rails.logger.info "  Scooters: #{full_data[:scooters]&.count || 0}"
    Rails.logger.info "  Rentals: #{full_data[:rentals]&.count || 0}"
    
    @data = full_data
    save_data
    
    Rails.logger.info "Data saved to #{@filepath}"
  end
  
  def full_data
    data.deep_dup
  end
  
  def clear!
    @data = { clients: [], scooters: [], rentals: [] }
    save_data
  end
  
  private
  
  def load_data
    if File.exist?(@filepath)
      content = File.read(@filepath)
      JSON.parse(content, symbolize_names: true)
    else
      # Создаем структуру по умолчанию
      { clients: [], scooters: [], rentals: [] }
    end
  rescue => e
    raise SRStorageError, "Failed to load data: #{e.message}"
  end
  
  def save_data
    FileUtils.mkdir_p(File.dirname(@filepath))
    
    json_data = data.deep_dup
    
    json_data.each do |collection_name, records|
      records.each do |record|
        record.each do |key, value|
          if value.is_a?(Time) || value.is_a?(DateTime)
            record[key] = value.iso8601
          elsif value.is_a?(Date)
            record[key] = value.to_s
          elsif value.is_a?(BigDecimal)
            record[key] = value.to_f
          end
        end
      end
    end
    
    File.write(@filepath, JSON.pretty_generate(json_data))
    Rails.logger.info "File written: #{@filepath}, size: #{File.size(@filepath)} bytes"
  end
  
  def save_collection(model_class, records)
    collection_name = model_class.name.underscore.pluralize.to_sym
    data[collection_name] = records
    save_data
  end
  
  def generate_id(records)
    if records.empty?
      1
    else
      max_id = records.map { |r| r[:id].to_i }.max
      max_id + 1
    end
  end
end