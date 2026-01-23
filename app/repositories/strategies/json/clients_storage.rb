require 'ostruct'
  module Strategies
    module Json
      class ClientsStorage
        FILE_PATH = Rails.root.join("backup", "clients.json")

        def all
          load_data.map { |attrs| 
            client = Strategies::Json::Client.new(attrs)
            client
          }
        end

        def find(id)
          data = load_data.find { |r| r["id"] == id.to_i }
          client = Strategies::Json::Client.new(data)
          client
        end

        def create(attrs)
          data = load_data

          attrs["id"] = next_id(data)
          data << attrs.to_unsafe_h.to_hash
          save_data(data)
          attrs
        end


        def update(id, attrs)
          data = load_data
          client = data.find { |r| r["id"] == id.to_i }
          return nil unless client


          client.merge!(attrs.stringify_keys)
          save_data(data)
          client
        end

        def destroy(id)
          data = load_data
          data.reject! { |r| r["id"] == id.to_i }
          save_data(data)
        end

        private

        def find_client(id)
          client_data = JSON.parse(File.read(Rails.root.join("backup", "clients.json"))).find { |c| c["id"] == id.to_i }
          Strategies::Json::Client.new(client_data)
        end

        def load_data
          return [] unless File.exist?(FILE_PATH)
          JSON.parse(File.read(FILE_PATH))
        end

        def save_data(data)
          File.write(FILE_PATH, JSON.pretty_generate(data))
        end

        def next_id(data)
          data.map { |r| r["id"] }.max.to_i + 1
        end
      end
    end
  end
