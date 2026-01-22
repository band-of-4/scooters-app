module Strategies
  module Json
    class Rental
      attr_accessor :id, :client_id, :created_at, :start_time, :end_time, :scooter_id, :status, :total_cost, :updated_at, :client, :scooter
      def initialize(hash)
        @id = hash["id"]
        @client_id = hash["client_id"]
        @created_at = parse_time(hash["created_at"])
        @start_time = parse_time(hash["start_time"])
        @end_time = parse_time(hash["end_time"])
        @scooter_id = hash["scooter_id"]
        @status = hash["status"]
        @total_cost = hash["total_cost"]
        @updated_at = hash["updated_at"]
      end

      def to_model 
        self
      end

      def model_name
        ActiveModel::Name.new(self, nil, self.class.name.demodulize)
      end

      def to_param
        id.to_s
      end
      
      def persisted?
        !@id.nil?
      end

      def errors
        ActiveModel::Errors.new(self)
      end

      private 

      def parse_time(value)
        return nil if value.blank?

        Time.parse(value)
      end
    end
  end
end