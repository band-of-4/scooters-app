module Strategies
  module Json
    class Client
      attr_accessor :id, :last_name, :first_name, :patronymic, :email, :phone, :date_of_birth, :total_rentals_count, :total_spent, :balance
      def initialize(hash)
        @id = hash["id"]
        @last_name = hash["last_name"]
        @first_name = hash["first_name"]
        @patronymic = hash["patronymic"]
        @email = hash["email"]
        @phone = hash["phone"]
        @date_of_birth = parse_time(hash["date_of_birth"])
        @total_rentals_count = hash["total_rentals_count"]
        @total_spent = hash["total_spent"]
        @balance = hash["balance"]
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