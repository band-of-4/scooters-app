class UpdateCommand < BaseCommand
  def execute
    uuid = @params[0]
    new_attributes = @params[1]
    
    record = @model_class.find_by(uuid: uuid)
    @backup = { old_attributes: record.attributes.dup }
    
    if record.update(new_attributes)
      [record, true]
    else
      [record, false]
    end
  end
  
  def undo
    return false unless @backup
    
    record = @model_class.find_by(uuid: @params[0])
    record.update(@backup[:old_attributes])
    true
  end
end