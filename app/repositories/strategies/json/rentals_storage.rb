require "active_support/core_ext/hash"
require "active_support/json"
require 'ostruct'
  module Strategies
    module Json
      class RentalsStorage
        FILE_PATH = Rails.root.join("backup", "rentals.json")

        def all
          puts '1'
          load_data.map { |attrs| 
            rental = Strategies::Json::Rental.new(attrs)
            rental.client= find_client(attrs["client_id"])
            rental.scooter= find_scooter(attrs["scooter_id"])
            rental 
          }
        end

        def find(id)
          puts '2'
          data = load_data.find { |r| r["id"] == id.to_i }
          rental = Strategies::Json::Rental.new(data)
          rental.client= find_client(data["client_id"])
          rental.scooter= find_scooter(data["scooter_id"])
          rental 
        end

        def create(attrs)
          puts '3'
          data = load_data

          attrs["id"] = next_id(data)
          data << attrs
          save_data(data)
          attrs
        end


        def update(id, attrs)
          puts '4'
          data = load_data
          rental = data.find { |r| r["id"] == id.to_i }
          return nil unless rental

          rental.merge!(attrs.stringify_keys)
          save_data(data)
          rental
        end

        def destroy(id)
          puts '5'
          data = load_data
          data.reject! { |r| r["id"] == id.to_i }
          save_data(data)
        end

        private

        def find_client(id)
          client_data = JSON.parse(File.read(Rails.root.join("backup", "clients.json"))).find { |c| c["id"] == id.to_i }
          Strategies::Json::Client.new(client_data)
        end

        def find_scooter(id)
          scooter_data = JSON.parse(File.read(Rails.root.join("backup", "scooters.json"))).find { |c| c["id"] == id.to_i }
          Strategies::Json::Scooter.new(scooter_data)
        end

  
        def ruby_string_to_hash(str)
          cleaned = str
            .gsub("=>", ":")
            .gsub(/(\w+):/, '"\1":')

          JSON.parse(cleaned)
        end


        def load_data
          return [] unless File.exist?(FILE_PATH)
          JSON.parse(File.read(FILE_PATH))
        end

        def save_data(data)
          puts "SAVING THEM"
          #puts ruby_string_to_hash(data)
          File.write(FILE_PATH, JSON.pretty_generate(data))
        end

        def next_id(data)
          data.map { |r| r["id"] }.max.to_i + 1
        end
      end
    end
  end
