
  module Strategies
    module ActiveRecord
      class RentalsStorage
        def all
          Rental.includes(:client, :scooter).order(created_at: :desc)
        end

        def find(id)
          Rental.find(id)
        end

        def create(attrs)
          puts attrs
          Rental.create(attrs)
        end

        def update(id, attrs)
          puts attrs
          puts 'Postgre'
          rental = Rental.find(id)
          rental.update(attrs)
          rental
        end

        def destroy(id)
          Rental.find(id).destroy
        end
      end
    end
  end