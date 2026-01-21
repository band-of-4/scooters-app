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
    @rental = Rental.new(rental_params)

    if @rental.save
      redirect_to @rental, notice: "Аренда успешно создана!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @rental.update(rental_params)
      redirect_to @rental, notice: "Аренда успешно обновлена!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rental.destroy
    redirect_to rentals_path, notice: "Аренда удалена!"
  end

  private

  def set_rental
    @rental = Rental.find(params[:id])
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
end
