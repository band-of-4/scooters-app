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
  

  #before_update :delegate_update_to_state

  #before_destroy :delegate_delete_to_state


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


  # Методы для работы со StorageSwitcher
  class << self
    def storage
      StorageSwitcher.current
    end
    
    def all
      if StorageSwitcher.database_mode?
        super
      else
        storage.all(self).map { |attrs| instantiate_from_storage(attrs) }
      end
    end
    
    def find(id)
      if StorageSwitcher.database_mode?
        super
      else
        attrs = storage.find(self, id)
        instantiate_from_storage(attrs)
      end
    end
    
    def find_by(conditions)
      if StorageSwitcher.database_mode?
        super
      else
        attrs = storage.find_by(self, conditions)
        attrs ? instantiate_from_storage(attrs) : nil
      end
    end
    
    def where(conditions)
      if StorageSwitcher.database_mode?
        super
      else
        storage.where(self, conditions).map { |attrs| instantiate_from_storage(attrs) }
      end
    end
    
    def includes(*associations)
      if StorageSwitcher.database_mode?
        super
      else
        # В файловом режиме возвращаем объект, который может имитировать Relation
        FileStorageRelation.new(all)
      end
    end
    
    def count
      if StorageSwitcher.database_mode?
        super
      else
        storage.count(self)
      end
    end
    
    private
    
    def instantiate_from_storage(attributes)
      attrs = attributes.dup
      attrs[:id] = attrs[:id].to_i if attrs[:id]
      attrs[:client_id] = attrs[:client_id].to_i if attrs[:client_id]
      attrs[:scooter_id] = attrs[:scooter_id].to_i if attrs[:scooter_id]
      
      # Преобразуем временные метки
      [:start_time, :end_time, :created_at, :updated_at].each do |time_field|
        if attrs[time_field].is_a?(String)
          attrs[time_field] = Time.parse(attrs[time_field])
        end
      end
      
      # Преобразуем decimal поля
      [:total_cost].each do |field|
        if attrs[field].is_a?(String)
          attrs[field] = attrs[field].to_d
        end
      end
      
      new(attrs).tap do |record|
        record.instance_variable_set(:@new_record, false) if attrs[:id]
      end
    end
  end
  
  # Переопределяем методы экземпляра
  def save
    if StorageSwitcher.database_mode?
      super
    else
      return false unless valid?
      
      attributes_for_storage = attributes.symbolize_keys
      
      if new_record?
        result = self.class.storage.create(self.class, attributes_for_storage)
        self.id = result[:id]
      else
        self.class.storage.update(self.class, id, attributes_for_storage)
      end
      
      true
    end
  end
  
  def update(attributes)
    if StorageSwitcher.database_mode?
      super
    else
      assign_attributes(attributes)
      save
    end
  end
  
  def destroy
    if StorageSwitcher.database_mode?
      super
    else
      self.class.storage.destroy(self.class, id)
      freeze
    end
  end
  
  def persisted?
    if StorageSwitcher.database_mode?
      super
    else
      id.present?
    end
  end
  
  # Методы для доступа к связанным объектам в файловом режиме
  def client
    if StorageSwitcher.database_mode?
      super
    else
      @client ||= Client.find_by(id: client_id) if client_id
    end
  end
  
  def scooter
    if StorageSwitcher.database_mode?
      super
    else
      @scooter ||= Scooter.find_by(id: scooter_id) if scooter_id
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
    return if scooter.blank? || status != 'active'
    
    if scooter.status != 'available' && new_record?
      errors.add(:available_error, 'не доступен для аренды')
    end
  end
  
  def client_has_sufficient_balance
    return if client.blank? || total_cost.nil?

    if persisted? 
      old_cost, new_cost = [total_cost_in_database, total_cost]
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
    # Важно: client.update и scooter.update будут использовать наш StorageSwitcher
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