class Rental < ApplicationRecord
  belongs_to :scooter
  belongs_to :client
end
