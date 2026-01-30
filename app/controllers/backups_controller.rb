class BackupsController < ApplicationController
  require Rails.root.join("app", "services", "backup_service")
  require Rails.root.join("app", "services", "restore_service")
  before_action :set_backup, only: [ :download, :restore, :destroy ]

  def index
    @backups = BackupService.list_backups
    @formats = [ "json", "yaml" ]
  end

  def create
    format = params[:format] || "json"

    begin
      result = BackupService.create_backup(format: format)

      respond_to do |f|
        f.html do
          flash[:success] = "Backup created successfully: #{result[:filename]}"
          redirect_to backups_path
        end
        f.json { render json: result }
      end
    rescue ScooterRentalError::SRBackupError => e
      respond_to do |f|
        f.html do
          flash[:error] = "Backup failed: #{e.message}"
          redirect_to backups_path
        end
        f.json { render json: { error: e.message }, status: :unprocessable_entity }
      end
    end
  end

  def download
    filepath = Rails.root.join("storage", "backups", @backup_filename)

    if File.exist?(filepath)
      send_file filepath, filename: @backup_filename
    else
      flash[:error] = "Backup file not found"
      redirect_to backups_path
    end
  end

  def restore
  puts "=" * 80
  puts "RESTORE ACTION CALLED!"
  puts "Params: #{params.inspect}"
  puts "Backup filename: #{@backup_filename}"

  filepath = Rails.root.join("storage", "backups", @backup_filename)
  puts "Filepath: #{filepath}"
  puts "File exists: #{File.exist?(filepath)}"

  # Проверяем содержимое файла
  if File.exist?(filepath)
    content = File.read(filepath)
    puts "File size: #{content.bytesize} bytes"
    puts "First 200 chars: #{content[0..200]}"
  end

  begin
    puts "Calling RestoreService.restore_from_file..."
    result = RestoreService.restore_from_file(filepath)
    puts "RestoreService returned: #{result.inspect}"

    flash[:success] = "Database restored successfully! " \
                     "Restored #{result[:restored_records][:clients]} clients, " \
                     "#{result[:restored_records][:scooters]} scooters, " \
                     "#{result[:restored_records][:rentals]} rentals."

    puts "Redirecting to root_path..."
    redirect_to root_path

  rescue ScooterRentalError::SRRestoreError => e
    puts "RestoreError: #{e.message}"
    puts e.backtrace.first(5)

    flash[:error] = "Restore failed: #{e.message}"
    redirect_to backups_path

  rescue ScooterRentalError::SRValidationError => e
    puts "ValidationError: #{e.message}"

    flash[:error] = "Validation error during restore: #{e.message}"
    redirect_to backups_path

  rescue => e
    puts "Unexpected error: #{e.class}: #{e.message}"
    puts e.backtrace.first(10)

    flash[:error] = "Unexpected error: #{e.message}"
    redirect_to backups_path
  end

  puts "=" * 80
end

  def destroy
    filepath = Rails.root.join("storage", "backups", @backup_filename)

    if File.exist?(filepath)
      File.delete(filepath)
      flash[:success] = "Backup file deleted: #{@backup_filename}"
    else
      flash[:error] = "Backup file not found"
    end

    redirect_to backups_path
  end

  def upload
    uploaded_file = params[:backup_file]

    unless uploaded_file
      flash[:error] = "Please select a file"
      return redirect_to backups_path
    end

    # Проверяем расширение файла
    extension = File.extname(uploaded_file.original_filename).downcase
    unless [ ".json", ".yaml", ".yml" ].include?(extension)
      flash[:error] = "Invalid file format. Please upload JSON or YAML file"
      return redirect_to backups_path
    end

    # Сохраняем файл
    filename = "uploaded_#{Time.current.strftime('%Y%m%d_%H%M%S')}#{extension}"
    filepath = Rails.root.join("storage", "backups", filename)

    FileUtils.mkdir_p(File.dirname(filepath))
    File.write(filepath, uploaded_file.read.force_encoding("UTF-8"))
    flash[:success] = "File uploaded successfully: #{filename}"
    redirect_to backups_path
  end

  private

  def set_backup
    # Получаем имя файла (без расширения)
    backup_id = params[:id]

    # Ищем полное имя файла с любым расширением
    existing_backups = BackupService.list_backups

    # Ищем файл, который начинается с backup_id и имеет расширение
    @backup_filename = existing_backups.find do |backup|
        backup_name_without_ext = backup.gsub(/\.(json|yaml|yml)$/, "")
        backup_name_without_ext == backup_id
    end

    unless @backup_filename && File.exist?(Rails.root.join("storage", "backups", @backup_filename))
        flash[:error] = "Backup file not found"
        redirect_to backups_path
    end
  end
end
