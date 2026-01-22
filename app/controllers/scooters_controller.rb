# class ScootersController < ApplicationController
#   before_action :set_scooter, only: %i[show edit update destroy]

#   def index
#     @scooters = Scooter.all
#   end

#   def show
#     @scooter = Scooter.find(params[:id])
#   end


#   def new
#     @scooter = Scooter.new
#   end

#   def create
#     @scooter = Scooter.new(scooter_params)

#     if @scooter.save
#       redirect_to @scooter, notice: "Самокат успешно создан!"
#     else
#       render :new, status: :unprocessable_entity
#     end
#   end

#   def edit
#     set_scooter if @scooter.nil?
#   end

#   def update
#     if @scooter.update(scooter_params)
#       redirect_to @scooter, notice: "Самокат успешно обновлён!"
#     else
#       render :edit, status: :unprocessable_entity
#     end
#   end

#   def destroy
#     @scooter.destroy
#     redirect_to scooters_path, notice: "Самокат удалён!"
#   end

#   private

#   def set_scooter
#     @scooter = Scooter.find_by(id: params[:id])
#     rescue ActiveRecord::RecordNotFound
#       @scooter = nil
#   end

#   def scooter_params
#     params.require(:scooter).permit(:model, :serial_number, :minute_rate, :status)
#   end
# en


class ScootersController < ApplicationController
  before_action :set_scooter, only: %i[show edit update destroy]

  def index
    @scooters = scooters_repo.all
  end

  def show
  end

  def new
    @scooter = scooters_repo.build
  end

  def create
    @scooter = scooters_repo.create(scooter_params)

    if @scooter
      redirect_to scooters_path, notice: "Самокат успешно создан!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if scooters_repo.update(params[:id], scooter_params)
      redirect_to scooter_path(params[:id]), notice: "Самокат успешно обновлен!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    scooters_repo.destroy(params[:id])
    redirect_to scooters_path, notice: "Самокат удален!"
  end

  private

  def scooter_params
    params.require(:scooter).permit(:model, :serial_number, :minute_rate, :status)
  end


  def set_scooter
    @scooter = scooters_repo.find(params[:id])
  end

  def scooters_repo
    @scooters_repo ||= ScootersRepository.new
  end
end
