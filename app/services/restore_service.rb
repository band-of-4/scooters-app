require Rails.root.join('app', 'exceptions', 'scooter_rental_error')

class RestoreService
  def self.restore_from_file(filepath)
    puts "=" * 80
    puts "RestoreService.restore_from_file called"
    puts "Filepath: #{filepath}"
    
    raise SRRestoreError, "File not found: #{filepath}" unless File.exist?(filepath)
    
    content = File.read(filepath)
    puts "File size: #{content.bytesize} bytes"
    
    extension = File.extname(filepath).downcase
    puts "File extension: #{extension}"
    
    data = parse_content(content, extension)
    puts "Data parsed successfully"
    puts "Data keys: #{data.keys}"
    puts "Records count:"
    puts "  Clients: #{data[:clients]&.count || 0}"
    puts "  Scooters: #{data[:scooters]&.count || 0}"
    puts "  Rentals: #{data[:rentals]&.count || 0}"
    
    validate_data_structure(data)
    puts "Data structure validation passed"
    
    puts "Starting database transaction..."
    ActiveRecord::Base.transaction do
        puts "Clearing existing data..."
        
        puts "Before clear:"
        puts "  Clients: #{Client.count}"
        puts "  Scooters: #{Scooter.count}"
        puts "  Rentals: #{Rental.count}"
        
        Rental.delete_all
        Client.delete_all
        Scooter.delete_all
        
        puts "After clear:"
        puts "  Clients: #{Client.count}"
        puts "  Scooters: #{Scooter.count}"
        puts "  Rentals: #{Rental.count}"
        
        puts "Restoring new data..."
        
        @client_id_mapping = {}
        @scooter_id_mapping = {}
        
        restore_scooters(data[:scooters])
        puts "  Scooters restored: #{Scooter.count}"
        
        restore_clients(data[:clients])
        puts "  Clients restored: #{Client.count}"
        
        restore_rentals(data[:rentals])
        puts "  Rentals restored: #{Rental.count}"
        
        puts "Restore completed within transaction"
    end
    
    puts "Transaction committed successfully"
    
    result = {
        success: true,
        restored_records: {
        clients: Client.count,
        scooters: Scooter.count,
        rentals: Rental.count
        }
    }
    
    puts "Returning result: #{result.inspect}"
    puts "=" * 80
    
    result
    
    rescue => e
    puts "ERROR in RestoreService: #{e.class}: #{e.message}"
    puts e.backtrace.first(10)
    raise
  end
  
  private
  
  def self.parse_content(content, extension)
  puts "Parsing content with extension: #{extension}"
  
  case extension.downcase
  when '.json'
    puts "Parsing as JSON..."
    result = JSON.parse(content, symbolize_names: true)
    puts "JSON parsing successful"
  when '.yaml', '.yml'
    puts "Parsing as YAML..."
    result = YAML.safe_load(content, symbolize_names: true, permitted_classes: [Time, Date, Symbol])
    puts "YAML parsing successful"
  else
    puts "Unsupported extension: #{extension}"
    raise SRRestoreError, "Unsupported file format: #{extension}"
  end
  
  result
rescue => e
  puts "Parse error: #{e.message}"
  raise SRRestoreError, "Failed to parse file: #{e.message}"
end
  
  def self.validate_data_structure(data)
    raise SRRestoreError, "Invalid backup file structure" unless data.is_a?(Hash)
    
    required_keys = [:clients, :scooters, :rentals]
    missing_keys = required_keys - data.keys
    
    unless missing_keys.empty?
      raise SRRestoreError, "Missing required data sections: #{missing_keys.join(', ')}"
    end
  end
  
  def self.restore_scooters(scooters_data)
  puts "Restoring #{scooters_data&.count || 0} scooters..."
  return if scooters_data.nil? || scooters_data.empty?
  
  scooters_data.each_with_index do |scooter_attrs, index|
    original_id = scooter_attrs[:id]
    
    attrs = scooter_attrs.dup
    
    attrs.delete(:id)
    attrs.delete(:created_at)
    attrs.delete(:updated_at)
    
    if attrs[:status] == 'avaliable'
      attrs[:status] = 'available'
    end
    
    puts "  Creating scooter #{index + 1}: #{attrs[:model]} (original id: #{original_id})"
    
    begin
      scooter = Scooter.create!(attrs)
      @scooter_id_mapping[original_id] = scooter.id if original_id
    rescue => e
      puts "  ERROR creating scooter: #{e.message}"
      puts "  Attributes: #{attrs.inspect}"
      raise
    end
  end
  puts "Scooters restoration completed"
  puts "ID mapping: #{@scooter_id_mapping.inspect}"
end
  
  def self.restore_clients(clients_data)
  puts "Restoring #{clients_data&.count || 0} clients..."
  return if clients_data.nil? || clients_data.empty?
  
  clients_data.each_with_index do |client_attrs, index|
    original_id = client_attrs[:id]
    
    attrs = client_attrs.dup
    
    attrs.delete(:id)
    attrs.delete(:created_at)
    attrs.delete(:updated_at)
    
    if attrs[:date_of_birth].is_a?(String)
      attrs[:date_of_birth] = Date.parse(attrs[:date_of_birth])
    end
    
    puts "  Creating client #{index + 1}: #{attrs[:last_name]} #{attrs[:first_name]} (original id: #{original_id})"
    
    begin
      client = Client.create!(attrs)
      @client_id_mapping[original_id] = client.id if original_id
    rescue => e
      puts "  ERROR creating client: #{e.message}"
      puts "  Attributes: #{attrs.inspect}"
      raise
    end
  end
  puts "Clients restoration completed"
  puts "ID mapping: #{@client_id_mapping.inspect}"
end
  
  def self.restore_rentals(rentals_data)
    puts "Restoring #{rentals_data&.count || 0} rentals..."
    return if rentals_data.nil? || rentals_data.empty?
    
    rentals_data.each_with_index do |rental_attrs, index|
        attrs = rental_attrs.dup
        
        attrs.delete(:id)
        attrs.delete(:created_at)
        attrs.delete(:updated_at)
        
        [:start_time, :end_time].each do |time_field|
        if attrs[time_field].is_a?(String)
            attrs[time_field] = Time.parse(attrs[time_field])
        end
        end
        
        original_client_id = rental_attrs[:client_id]
        original_scooter_id = rental_attrs[:scooter_id]
        
        new_client_id = @client_id_mapping[original_client_id]
        new_scooter_id = @scooter_id_mapping[original_scooter_id]
        
        puts "  Creating rental #{index + 1}:"
        puts "    Original client_id: #{original_client_id} -> new: #{new_client_id}"
        puts "    Original scooter_id: #{original_scooter_id} -> new: #{new_scooter_id}"
        
        unless new_client_id && new_scooter_id
        raise SRRestoreError, "Cannot find client or scooter for rental. Client mapping: #{@client_id_mapping.inspect}, Scooter mapping: #{@scooter_id_mapping.inspect}"
        end
        
        client = Client.find_by(id: new_client_id)
        scooter = Scooter.find_by(id: new_scooter_id)
        
        unless client && scooter
        raise SRRestoreError, "Cannot find client or scooter for rental (after mapping)"
        end
        

        original_status = scooter.status
        puts "    Scooter original status: #{original_status}, Rental status: #{rental_attrs[:status]}"
        
        if rental_attrs[:status] == 'active' && scooter.status != 'available'
        puts "    Temporarily changing scooter status from #{scooter.status} to 'available'"
        scooter.update_column(:status, 'available') # update_column чтобы не запускать колбэки
        end
        
        begin
        puts "    Creating rental with attributes: #{attrs.inspect}"
        Rental.skip_callback(:validate, :client_has_sufficient_balance)
        rental = Rental.create!(attrs.merge(client: client, scooter: scooter))
        puts "    Rental created successfully"
        Rental.set_callback(:validate, :client_has_sufficient_balance)
        
        if original_status != scooter.status
            puts "    Restoring scooter status to #{original_status}"
            scooter.update_column(:status, original_status)
        end
        
        rescue => e
        puts "    ERROR creating rental: #{e.message}"
        if original_status != scooter.status
            puts "    Restoring scooter status to #{original_status} after error"
            scooter.update_column(:status, original_status)
        end
        raise e
        end
    end
    puts "Rentals restoration completed"
    end
end