module Queries 
  class TopClientsQuery
    def self.call(limit = 10)
      Client
        .where("total_spent > 0")
        .order(total_spent: :desc)
        .limit(limit)
    end
  end
end
