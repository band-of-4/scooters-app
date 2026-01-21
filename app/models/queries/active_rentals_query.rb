module Queries
  class ActiveRentalsQuery
    def self.call
      Rental.includes(:client, :scooter)
            .where(status: 'active') 
            .order(start_time: :asc)        
    end
  end
end
