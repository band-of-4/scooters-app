require 'ostruct'
  module Strategies
    module Json
      class RentalsStorage
        FILE_PATH = Rails.root.join("backup", "rentals.json")

        def all
          puts 'ALL'
          load_data.map { |attrs| puts attrs["client_id"]
            build_rental(attrs) }
        end

        def find(id)
          load_data.find { |r| r["id"] == id.to_i }
        end

        def create(attrs)
          data = load_data

          attrs["id"] = next_id(data)
          data << attrs
          save_data(data)
          attrs
        end


        def update(id, attrs)
          puts attrs
          puts 'JSON'
          data = load_data
          rental = data.find { |r| r["id"] == id.to_i }
          return nil unless rental

          rental.merge!(attrs.stringify_keys)
          save_data(data)
          rental
        end

        def destroy(id)
          data = load_data
          data.reject! { |r| r["id"] == id.to_i }
          save_data(data)
        end

        private

        def build_rental(attrs)
          puts attrs["client_id"]
          rental = OpenStruct.new(attrs)
          def rental.client
            @client ||= begin
              client_data = JSON.parse(File.read(Rails.root.join("backup", "clients.json"))).find { |c| c["id"] == 2 }
              puts 'Data right here'
              puts client_data
              OpenStruct.new(client_data) if client_data
            end
          end

          def rental.scooter
            @scooter ||= begin
              scooter_data = JSON.parse(File.read(Rails.root.join("backup/scooters.json"))).find { |s| s["id"] == scooter_id }
              OpenStruct.new(scooter_data) if scooter_data
            end
          end

          def rental.persisted?
            id.present?
          end

          rental
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
