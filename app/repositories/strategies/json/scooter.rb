module Strategies
  module Json
    class Scooter
      attr_accessor :id, :model, :serial_number, :minute_rate, :status
      def initialize(hash)
        @id = hash["id"]
        @model = hash["model"]
        @serial_number = hash["serial_number"]
        @minimum_rate = hash["minimum_rate"]
        @status = hash["status"]
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
    end
  end
end