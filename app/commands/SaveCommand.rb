class SaveCommand < BaseCommand
  def execute
    attributes = @params[0]

    if @backup && @backup[:uuid]
      attributes = attributes.merge(uuid: @backup[:uuid])
    end

    record = @model_class.new(attributes)
    
    if record.save
      @backup = { uuid: record.uuid }
      [record, true]
    else
      [record, false]
    end
  end
  
  def undo
    return false unless @backup
    
    record = @model_class.find_by(uuid: @backup[:uuid])
    record&.destroy
    true
  end
end