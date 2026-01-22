
  module Strategies
    module ActiveRecord
      class ClientsStorage
        def all
          Client.all
        end

        def find(id)
          Client.find(id)
        end

        def create(attrs)
          Client.create(attrs)
        end

        def update(id, attrs)
          client = Client.find(id)
          client.update(attrs)
          client
        end

        def destroy(id)
          Client.find(id).destroy
        end
      end
    end
  end