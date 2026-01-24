class Client < ApplicationRecord
  has_many :rentals, dependent: :restrict_with_error
  has_many :scooters, through: :rentals
  
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :patronymic, length: { maximum: 50 }, allow_blank: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A[A-Za-z0-9.%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\z/ }
  validates :phone, presence: true, uniqueness: true, format: { with: /\A(\+7|8)?[\s\-]?\(?\d{3}\)?[\s\-]?\d{3}[\s\-]?\d{2}[\s\-]?\d{2}\z/ }
  validates :date_of_birth, presence: true
  validates :total_rentals_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_spent, numericality: { greater_than_or_equal_to: 0 }
  validates :balance, numericality: true
  
  validate :age_must_be_at_least_18
  
  # Методы для работы со StorageSwitcher
  class << self
    def storage
      StorageSwitcher.current
    end
    
    # Переопределяем методы запросов
    def all
      if StorageSwitcher.database_mode?
        super
      else
        # В файловом режиме создаем объекты из данных
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
      # Преобразуем символьные ключи и строковые значения
      attrs = attributes.dup
      attrs[:id] = attrs[:id].to_i if attrs[:id]
      
      # Преобразуем даты
      if attrs[:date_of_birth].is_a?(String)
        attrs[:date_of_birth] = Date.parse(attrs[:date_of_birth])
      end
      
      # Преобразуем decimal поля
      [:balance, :total_spent].each do |field|
        if attrs[field].is_a?(String)
          attrs[field] = attrs[field].to_d
        end
      end
      
      new(attrs).tap do |record|
        # Помечаем как persisted, если есть ID
        record.instance_variable_set(:@new_record, false) if attrs[:id]
      end
    end
  end
  
  # Переопределяем методы экземпляра
  def save
    if StorageSwitcher.database_mode?
      super
    else
      # Валидация
      return false unless valid?
      
      attributes_for_storage = attributes.symbolize_keys
      
      if new_record?
        # Создание
        result = self.class.storage.create(self.class, attributes_for_storage)
        self.id = result[:id]
      else
        # Обновление
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
  
  private
  
  def age_must_be_at_least_18
    return if date_of_birth.blank?
    
    if date_of_birth > 18.years.ago.to_date
      errors.add(:time_error, 'клиент должен быть старше 18 лет')
    end
  end
end