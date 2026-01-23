class Rental < ApplicationRecord
  belongs_to :scooter
  belongs_to :client
  
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true, inclusion: { in: ['active', 'completed', 'cancelled'] }
  validates :total_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  validate :end_time_after_start_time
  validate :scooter_available_for_rental
  validate :client_has_sufficient_balance, on: [:create, :update]


  
  before_validation :calculate_total_cost, if: -> { end_time.present? && start_time.present? }
  

  before_update :delegate_update_to_state

  before_destroy :delegate_delete_to_state


  after_create :change_client
  after_destroy :refund_client
  after_update :recalculate_client_balance, if: :saved_change_to_total_cost?

  def state
    @state = case status
               when 'active'    then ActiveRentalState.new(self)
               when 'completed' then CompletedRentalState.new(self)
               when 'cancelled' then CancelledRentalState.new(self)
               end
  end

  private
  
  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    
    if end_time <= start_time
      errors.add(:time_error, 'должно быть позже времени начала')
    end
  end
  
  def scooter_available_for_rental
    return if scooter.blank?
    
    if scooter.status != 'available' && new_record?
      errors.add(:available_error, 'не доступен для аренды')
    end
  end
  
  def client_has_sufficient_balance
    return if client.blank? || total_cost.nil?

    if persisted? && will_save_change_to_total_cost?
      old_cost, new_cost = total_cost_change_to_be_saved
      difference = new_cost - old_cost

      if difference > 0 && client.balance < difference
        errors.add(:client_balance_error, "недостаточно средств для продления аренды")
      end
    elsif new_record?
      if client.balance < total_cost
        errors.add(:client_balance_error, "недостаточно средств для аренды")
      end
    end
  end

  
  def calculate_total_cost
    return if end_time.blank? || start_time.blank?
    
    minutes = ((end_time - start_time) / 60).ceil
    base_cost = minutes * scooter.minute_rate

    decorated_client = AgeDiscountDecorator.new(client)
    self.total_cost = base_cost * decorated_client.discount_multiplier
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
    scooter.update(
      status: "rented"
    )
  end

  def refund_client
    client.update(
      balance: client.balance + total_cost,
      total_spent: client.total_spent - total_cost,
      total_rentals_count: client.total_rentals_count - 1
    )
    scooter

  end

  def recalculate_client_balance
    old_cost, new_cost = saved_change_to_total_cost
    difference = new_cost - old_cost

    client.update(
      balance: client.balance - difference,
      total_spent: client.total_spent.to_f + difference
    )
  end
  
  def delegate_update_to_state
    unless @state.on_update?
      errors.add(:base, "Нельзя изменить аренду в текущем состоянии")
      throw(:abort)
    end
  end

  def delegate_delete_to_state
    unless @state.on_delete?
      errors.add(:base, "Нельзя удалить аренду в текущем состоянии")
      throw(:abort)
    end
  end

end