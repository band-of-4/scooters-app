
  module Strategies
    module ActiveRecord
      class ScootersStorage
        def all
          Scooter.all
        end

        def find(id)
          Scooter.find(id)
        end

        def create(attrs)
          Scootet.create(attrs)
        end

        def update(id, attrs)
          scooter = Scooter.find(id)
          scooter.update(attrs)
          scooter
        end

        def destroy(id)
          Scooter.find(id).destroy
        end
      end
    end
  end