class StorageModeController < ApplicationController
  before_action :check_current_mode, only: [:index]
  
  def index
    @current_mode = StorageSwitcher.current_mode
    @backups = BackupService.list_backups
  end
  
  def switch_to_file
    begin
      StorageSwitcher.switch_to_file!(backup_first: true)
      
      flash[:success] = "Переключено в оффлайн-режим. Теперь данные сохраняются в файл."
      redirect_to storage_mode_index_path
    rescue => e
      flash[:error] = "Ошибка при переключении в оффлайн-режим: #{e.message}"
      redirect_to storage_mode_index_path
    end
  end
  
  def switch_to_database
    begin
      StorageSwitcher.switch_to_database!
      
      flash[:success] = "Переключено в онлайн-режим. Теперь данные сохраняются в БД."
      redirect_to storage_mode_index_path
    rescue => e
      flash[:error] = "Ошибка при переключении в онлайн-режим: #{e.message}"
      redirect_to storage_mode_index_path
    end
  end
  
  def create_backup_from_file
    begin
      result = StorageSwitcher.create_backup_from_current_data("offline_work")
      
      flash[:success] = "Бекап создан: #{result[:filename]}"
      redirect_to storage_mode_index_path
    rescue => e
      flash[:error] = "Ошибка при создании бекапа: #{e.message}"
      redirect_to storage_mode_index_path
    end
  end
  
  def restore_from_file_backup
    filename = params[:filename]
    
    begin
      # Переключаемся в режим БД, если еще не в нем
      StorageSwitcher.switch_to_database! unless StorageSwitcher.database_mode?
      
      # Восстанавливаем из бекапа
      filepath = Rails.root.join('storage', 'backups', filename)
      RestoreService.restore_from_file(filepath)
      
      flash[:success] = "База данных восстановлена из бекапа: #{filename}"
      redirect_to root_path
    rescue => e
      flash[:error] = "Ошибка при восстановлении: #{e.message}"
      redirect_to storage_mode_index_path
    end
  end
  
  private
  
  def check_current_mode
    # Инициализируем режим, если еще не инициализирован
    StorageSwitcher.current
  end
end