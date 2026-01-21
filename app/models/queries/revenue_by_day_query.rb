module Queries
  class RevenueByDayQuery
    def self.call
      Rental
        .where("total_cost > 0")                  
        .group("DATE(start_time)")                
        .select("DATE(start_time) as day, SUM(total_cost) as revenue")
        .order("day DESC")                        
    end
  end
end
