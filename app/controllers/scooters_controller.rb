class ScootersController < ApplicationController
  def index
    @scooters = Scooter.where(status: "available")
  end

  def show
    @scooter = Scooter.find(params[:id])
  end
end
