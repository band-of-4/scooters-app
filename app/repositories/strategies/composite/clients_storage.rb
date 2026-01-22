
  module Strategies
    module Composite
      class ClientsStorage
        def initialize
          @primary = Strategies::ActiveRecord::ClientsStorage.new
          @replica = Strategies::Json::ClientsStorage.new
        end

        def all
          primary_alive? ? @primary.all : @replica.all
        end

        def find(id)
          primary_alive? ? @primary.find(id) : @replica.find(id)
        end

        def create(attrs)
          if primary_alive?
            record = @primary.create(attrs)
            @replica.create(record.attributes)
            record
          else
            @replica.create(attrs)
          end
        end

        def update(id, attrs)
          if primary_alive?
            @primary.update(id, attrs)
            @replica.update(id, attrs)
          else
            @replica.update(id, attrs)
          end
        end

        def destroy(id)
          if primary_alive?
            @primary.destroy(id)
            @replica.destroy(id)
          else
            @replica.destroy(id)
          end
        end

        private

        def primary_alive?
          ::ActiveRecord::Base.connection.active?
        rescue
          false
        end
      end
    end
  end
