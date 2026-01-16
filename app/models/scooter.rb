class Scooter < ApplicationRecord
  has_many :rentals, dependent: :restrict_with_error
  has_many :clients, through: :rentals
  
  validates :model, presence: true, length: { minimum: 2, maximum: 50 }
  validates :serial_number, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :status, presence: true, inclusion: { in: ['available', 'rented', 'maintenance', 'broken'] }
  validates :minute_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  #scope - предопределенный запросы к БД, очень похожи на методы класса
  #Scooter.available ~ SELECT * FROM scooters WHERE status = 'available'
  scope :available, -> { where(status: 'available') }
  scope :rented, -> { where(status: 'rented') }
  scope :under_maintenance, -> { where(status: 'maintenance') }
end
