class RentalsController < ApplicationController
  before_action :set_rental, only: %i[show edit update destroy]

  def index
    @rentals = Rental.includes(:client, :scooter).order(created_at: :desc)
  end

  def show
  end

  def new
    @rental = Rental.new(start_time: Time.current)
  end

  def create
    command = SaveCommand.new(Rental, rental_params)
    @rental, success = command_manager.execute(command)
    # @rental.state
    if success
      redirect_to @rental, notice: "Аренда успешно создана!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    command = UpdateCommand.new(Rental, @rental.uuid, rental_params)
    @rental, success = command_manager.execute(command)
    # @rental.state

    if success
      redirect_to @rental, notice: "Аренда успешно обновлена!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # @rental.state
    command = DestroyCommand.new(Rental, @rental.uuid)

    command_manager.execute(command)
    redirect_to rentals_path, notice: "Аренда удалена!"
  end

  def undo
    if command_manager.undo
      redirect_to rentals_path, notice: "Отменено"
    else
      redirect_to rentals_path, alert: "Нечего отменять"
    end
  end

  def redo
    if command_manager.redo
      redirect_to rentals_path, notice: "Повторено"
    else
      redirect_to rentals_path, alert: "Нечего повторять"
    end
  end

  private

  def set_rental
    if StorageSwitcher.database_mode?
      @rental = Rental.find_by(id: params[:id])
    else
      @rental = Rental.all.find { |s| s.id.to_s == params[:id].to_s }
    end
    rescue ActiveRecord::RecordNotFound
      @rental = nil
  end

  def rental_params
    params.require(:rental).permit(
      :client_id,
      :scooter_id,
      :start_time,
      :end_time,
      :status,
      :total_cost
    )
  end

  def command_manager
    @command_manager ||= CommandManager.new(Rental, session.id)
  end
end
