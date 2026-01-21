class ReportsController < ApplicationController
  def top_clients
    @clients = Queries::TopClientsQuery.call(10)
  end

  def revenue
    @revenue_by_day = Queries::RevenueByDayQuery.call
  end

  def active_rentals
    @rentals = Queries::ActiveRentalsQuery.call
  end

end
