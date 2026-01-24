class ScootersController < ApplicationController
  before_action :set_scooter, only: %i[show edit update destroy]

  def index
    @scooters = Scooter.all
  end

  def show
  end


  def new
    @scooter = Scooter.new
  end

  def create
    command = SaveCommand.new(Scooter, scooter_params)
    @scooter, success = command_manager.execute(command)
    if success
      redirect_to @scooter, notice: "Самокат успешно создан!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    set_scooter if @scooter.nil?
  end

  def update
    command = UpdateCommand.new(Scooter, @scooter.uuid, scooter_params)
    @scooter, success = command_manager.execute(command)
    if success
      redirect_to @scooter, notice: "Самокат успешно обновлён!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    command = DestroyCommand.new(Scooter, @scooter.uuid)
    
    command_manager.execute(command)
    redirect_to scooters_path, notice: "Самокат удалён!"
  end

  def undo
    if command_manager.undo
      redirect_to scooters_path, notice: "Отменено"
    else
      redirect_to scooters_path, alert: "Нечего отменять"
    end
  end

  def redo
    if command_manager.redo
      redirect_to scooters_path, notice: "Повторено"
    else
      redirect_to scooters_path, alert: "Нечего повторять"
    end
  end

  private

  def set_scooter
    if StorageSwitcher.database_mode?
      @scooter = Scooter.find_by(id: params[:id])
    else
      # В файловом режиме ищем самокат
      @scooter = Scooter.all.find { |s| s.id.to_s == params[:id].to_s }
    end
    rescue ActiveRecord::RecordNotFound
      @scooter = nil
  end

  def scooter_params
    params.require(:scooter).permit(:model, :serial_number, :minute_rate, :status)
  end

  def command_manager
    @command_manager ||= CommandManager.new(Scooter, session.id)
  end
end
