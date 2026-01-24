class Scooter < ApplicationRecord
  has_many :rentals, dependent: :restrict_with_error
  has_many :clients, through: :rentals
  
  validates :model, presence: true, length: { minimum: 2, maximum: 50 }
  validates :serial_number, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :status, presence: true, inclusion: { in: ['available', 'rented', 'maintenance', 'broken'] }
  validates :minute_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  scope :available, -> { 
    if StorageSwitcher.database_mode?
      where(status: 'available') 
    else
      # В файловом режиме scope возвращает FileStorageRelation
      all.select { |s| s.status == 'available' }
    end
  }
  
  scope :rented, -> { 
    if StorageSwitcher.database_mode?
      where(status: 'rented') 
    else
      all.select { |s| s.status == 'rented' }
    end
  }
  
  scope :under_maintenance, -> { 
    if StorageSwitcher.database_mode?
      where(status: 'maintenance') 
    else
      all.select { |s| s.status == 'maintenance' }
    end
  }
  
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
      
      # Преобразуем decimal поля
      [:minute_rate].each do |field|
        if attrs[field].is_a?(String)
          attrs[field] = attrs[field].to_d
        end
      end
      
      # Fix: в схеме опечатка - 'avaliable' вместо 'available'
      if attrs[:status] == 'avaliable'
        attrs[:status] = 'available'
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
end