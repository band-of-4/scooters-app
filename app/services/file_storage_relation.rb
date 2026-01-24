class FileStorageRelation
  attr_reader :records
  
  def initialize(records)
    @records = records.is_a?(Array) ? records : records.to_a
  end
  
  
  def order(*args)
    if args.first.is_a?(Hash)
      field = args.first.keys.first
      direction = args.first.values.first
    elsif args.first.is_a?(String) || args.first.is_a?(Symbol)
      field = args.first
      direction = :asc
    else
      field = :id
      direction = :asc
    end
    
    sorted = records.sort_by { |r| r.send(field) }
    sorted = sorted.reverse if direction == :desc
    
    FileStorageRelation.new(sorted)
  end
  
  def where(conditions = {})
    filtered = records.select do |record|
      conditions.all? do |key, value|
        if value.is_a?(Array)
          value.include?(record.send(key))
        elsif value.is_a?(Range)
          value.cover?(record.send(key))
        else
          record.send(key) == value
        end
      end
    end
    
    FileStorageRelation.new(filtered)
  end
  
  def limit(number)
    FileStorageRelation.new(records.first(number))
  end
  
  def offset(number)
    FileStorageRelation.new(records.drop(number))
  end
  
  def count
    records.count
  end
  
  def any?
    records.any?
  end
  
  def empty?
    records.empty?
  end
  
  def present?
    records.present?
  end
  
  def first
    records.first
  end
  
  def last
    records.last
  end
  
  def to_a
    records
  end
  
  def each(&block)
    records.each(&block)
  end
  
  def map(&block)
    records.map(&block)
  end
  
  def select(&block)
    FileStorageRelation.new(records.select(&block))
  end
  
  delegate :[], :size, :length, :each_with_index, :find, :find_all, 
           :reject, :compact, :uniq, to: :records
           
  # Для совместимости с ActiveRecord::Relation
  def load
    self
  end
  
  def loaded?
    true
  end
  
  def klass
    records.first.class if records.any?
  end
end