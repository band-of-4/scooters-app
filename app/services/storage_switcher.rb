require Rails.root.join('app', 'exceptions', 'scooter_rental_error')

class StorageSwitcher
  @current_mode = :database
  @current_storage = nil
  
  class << self
    attr_accessor :current_mode, :current_storage
    
    def current
      @current_storage ||= DatabaseStorage.new
    end
    
    def switch_to_file!(backup_first: true)
      return if file_mode?
      
      Rails.logger.info "=== SWITCHING TO FILE MODE ==="
      
      if backup_first
        create_backup_before_switch
      end
      
      @current_storage = FileStorage.new
      @current_mode = :file
      
      initialize_file_storage
      
      check_data_transfer
      
      Rails.logger.info "=== SWITCHED TO FILE MODE SUCCESSFULLY ==="
      
      true
    end
    
    def switch_to_database!
      return if database_mode?
      
      @current_storage = DatabaseStorage.new
      @current_mode = :database
      
      true
    end
    
    def database_mode?
      @current_mode == :database
    end
    
    def file_mode?
      @current_mode == :file
    end
    
    def get_file_data_for_backup
      if file_mode?
        current.full_data
      else
        # Если мы в режиме БД, создаем временное файловое хранилище
        temp_storage = FileStorage.new
        temp_storage.full_data
      end
    end
    
    def create_backup_from_current_data(filename_prefix = "offline_backup")
      data = get_file_data_for_backup
      
      filename = "#{filename_prefix}_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json"
      filepath = Rails.root.join('storage', 'backups', filename)
      
      FileUtils.mkdir_p(File.dirname(filepath))
      File.write(filepath, JSON.pretty_generate(data))
      
      {
        success: true,
        filename: filename,
        filepath: filepath.to_s,
        created_at: Time.current
      }
    end
    
    private
    
    def create_backup_before_switch
      backup_result = BackupService.create_backup(format: :json)
      Rails.logger.info "Created backup before switching to file mode: #{backup_result[:filename]}"
    rescue => e
      Rails.logger.error "Failed to create backup before switch: #{e.message}"
    end
    
    def initialize_file_storage
  Rails.logger.info "Copying data from database to file storage..."
  
  clients_data = Client.unscoped.all.map do |client|
    client.attributes.transform_keys(&:to_sym).tap do |attrs|
      attrs.each do |key, value|
        if value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(ActiveSupport::TimeWithZone)
          attrs[key] = value.iso8601
        elsif value.is_a?(Date)
          attrs[key] = value.to_s
        end
      end
    end
  end
  
  scooters_data = Scooter.unscoped.all.map do |scooter|
    scooter.attributes.transform_keys(&:to_sym).tap do |attrs|
      attrs.each do |key, value|
        if value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(ActiveSupport::TimeWithZone)
          attrs[key] = value.iso8601
        elsif value.is_a?(Date)
          attrs[key] = value.to_s
        end
      end
    end
  end
  
  rentals_data = Rental.unscoped.all.map do |rental|
    rental.attributes.transform_keys(&:to_sym).tap do |attrs|
      attrs.each do |key, value|
        if value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(ActiveSupport::TimeWithZone)
          attrs[key] = value.iso8601
        elsif value.is_a?(Date)
          attrs[key] = value.to_s
        end
      end
    end
  end
  
  Rails.logger.info "Data loaded from DB:"
  Rails.logger.info "  Clients: #{clients_data.count}"
  Rails.logger.info "  Scooters: #{scooters_data.count}"
  Rails.logger.info "  Rentals: #{rentals_data.count}"
  
  data_to_save = {
    clients: clients_data,
    scooters: scooters_data,
    rentals: rentals_data
  }
  
  @current_storage.save_all(data_to_save)
  
  Rails.logger.info "Data saved to file storage"
end

    def load_from_database(model_class)
      model_class.all.map do |record|
        record.attributes.transform_keys(&:to_sym)
      end
    end

    def check_data_transfer
      return unless @current_storage.is_a?(FileStorage)
      
      file_data = @current_storage.full_data
      Rails.logger.info "Data in file storage after transfer:"
      Rails.logger.info "  Clients: #{file_data[:clients].count}"
      Rails.logger.info "  Scooters: #{file_data[:scooters].count}"
      Rails.logger.info "  Rentals: #{file_data[:rentals].count}"
      
      # Проверяем, что данные не пустые (если в БД были данные)
      db_has_data = Client.count > 0 || Scooter.count > 0 || Rental.count > 0
      file_has_data = file_data[:clients].count > 0 || file_data[:scooters].count > 0 || file_data[:rentals].count > 0
      
      if db_has_data && !file_has_data
        Rails.logger.error "Data transfer failed: DB has data but file storage is empty!"
      end
    end
  end
end