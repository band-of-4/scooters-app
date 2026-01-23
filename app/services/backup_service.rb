class BackupService
  class BackupError < StandardError; end
  
  def self.create_backup(format: :json)
    begin
      data = {
        clients: Client.all.as_json,
        scooters: Scooter.all.as_json,
        rentals: Rental.all.as_json
      }
      
      case format.to_sym
      when :json
        content = JSON.pretty_generate(data)
        extension = 'json'
      when :yaml
        content = data.to_yaml
        extension = 'yaml'
      else
        raise BackupError, "Unsupported format: #{format}"
      end
      
      filename = "backup_#{Time.current.strftime('%Y%m%d_%H%M%S')}.#{extension}"
      filepath = Rails.root.join('storage', 'backups', filename)
      
      # Создаем директорию если её нет
      FileUtils.mkdir_p(File.dirname(filepath))
      
      File.write(filepath, content)
      
      {
        success: true,
        filename: filename,
        filepath: filepath.to_s,
        format: format,
        created_at: Time.current
      }
    rescue => e
      raise BackupError, "Backup failed: #{e.message}"
    end
  end
  
  def self.list_backups
    backup_dir = Rails.root.join('storage', 'backups')
    return [] unless Dir.exist?(backup_dir)
    
    Dir.glob(File.join(backup_dir, '*.{json,yaml}'))
       .map { |f| File.basename(f) }
       .sort
       .reverse
  end
end