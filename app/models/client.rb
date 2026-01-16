class Client < ApplicationRecord
  has_many :rentals, dependent: :restrict_with_error
  has_many :scooters, through: :rentals
  
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :patronymic, length: { maximum: 50 }, allow_blank: true
  validates :email, presence: true, uniqueness: true, format: { with: /^[A-Za-z0-9.%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/ }
  validates :phone, presence: true, uniqueness: true, format: { with: /^(\+7|8)?[\s\-]?\(?\d{3}\)?[\s\-]?\d{3}[\s\-]?\d{2}[\s\-]?\d{2}$/ }
  validates :date_of_birth, presence: true
  validates :total_rentals_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_spent, numericality: { greater_than_or_equal_to: 0 }
  validates :balance, numericality: true
  
  validate :age_must_be_at_least_18
  
  private
  
  def age_must_be_at_least_18
    return if date_of_birth.blank?
    
    if date_of_birth > 18.years.ago.to_date
      errors.add(:date_of_birth, 'клиент должен быть старше 18 лет')
    end
  end
end