class BaseCommand
  attr_reader :model_class, :params, :backup
  
  def initialize(model_class, *params)
    @model_class = model_class
    @params = params
    @backup = nil
  end
  
  def execute
    raise NotImplementedError
  end
  
  def undo
    raise NotImplementedError
  end
  
  def serialize
    {
      command_class: self.class.name,
      model_class: @model_class.name,
      params: @params,
      backup: @backup,
      timestamp: Time.current.to_i
    }
  end
  
  def self.deserialize(hash)
    command_class = hash[:command_class].constantize
    model_class = hash[:model_class].constantize
    
    command = command_class.new(model_class, *hash[:params])
    command.instance_variable_set(:@backup, hash[:backup])
    command
  end
end