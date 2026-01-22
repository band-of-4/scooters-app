module Strategies
  module Json
    class Client
      attr_accessor :id, :last_name, :first_name
      def initialize(hash)
        @id = hash["id"]
        @last_name = hash["last_name"]
        @first_name = hash["first_name"]
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