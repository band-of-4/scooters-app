class ScootersController < ApplicationController
  before_action :set_scooter, only: %i[show edit update destroy]

  def index
    @scooters = Scooter.all
  end

  def show
    @scooter = Scooter.find(params[:id])
  end


  def new
    @scooter = Scooter.new
  end

  def create
    @scooter = Scooter.new(scooter_params)

    if @scooter.save
      redirect_to @scooter, notice: "Самокат успешно создан!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    set_scooter if @scooter.nil?
  end

  def update
    if @scooter.update(scooter_params)
      redirect_to @scooter, notice: "Самокат успешно обновлён!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @scooter.destroy
    redirect_to scooters_path, notice: "Самокат удалён!"
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
end
