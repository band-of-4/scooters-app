class Rental < ApplicationRecord
  belongs_to :scooter
  belongs_to :client
  
  validates :start_time, presence: true
  validates :status, presence: true, inclusion: { in: ['active', 'completed', 'cancelled'] }
  validates :total_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  validate :end_time_after_start_time
  validate :scooter_available_for_rental
  validate :client_has_sufficient_balance, on: :create
  
  before_validation :calculate_total_cost, if: -> { end_time.present? && start_time.present? }
  
  after_create :change_client
  after_destroy :refund_client
  after_update :recalculate_client_balance, if: :saved_change_to_total_cost?

  private
  
  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    
    if end_time <= start_time
      errors.add(:end_time, 'должно быть позже времени начала')
    end
  end
  
  def scooter_available_for_rental
    return if scooter.blank? || status == 'cancelled'
    
    if scooter.status != 'available' && new_record?
      errors.add(:scooter, 'не доступен для аренды')
    end
  end
  
  def client_has_sufficient_balance
    return if client.blank? || minute_cost.nil?
    
    if client.balance < 100
      errors.add(:client, 'недостаточно средств на балансе')
    end
  end
  
  def calculate_total_cost
    return if end_time.blank? || start_time.blank?
    
    minutes = ((end_time - start_time) / 60).ceil
    self.total_cost = minutes * scooter.minute_rate
  end
  
  def minute_cost
    scooter&.minute_rate || 0
  end

  def change_client
    client.update(
      balance: client.balance - total_cost,
      total_spent: client.total_spent + total_cost,
      total_rentals_count: client.total_rentals_count + 1
    )
  end

  def refund_client
    client.update(
      balance: client.balance + total_cost,
      total_spent: client.total_spent - total_cost,
      total_rentals_count: client.total_rentals_count - 1
    )
  end

  def recalculate_client_balance
    old_cost, new_cost = saved_change_to_total_cost
    difference = new_cost - old_cost

    client.update(
      balance: client.balance - difference,
      total_spent: client.total_spent.to_f + difference
    )
  end

end