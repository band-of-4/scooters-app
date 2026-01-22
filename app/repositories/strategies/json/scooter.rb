module Strategies
  module Json
    class Scooter
      attr_accessor :id, :model
      def initialize(hash)
        @id = hash["id"]
        @model = hash["model"]
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

      end
    end
  end
end