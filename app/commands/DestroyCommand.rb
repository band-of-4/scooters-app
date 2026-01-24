class DestroyCommand < BaseCommand
  def execute
    uuid = @params[0]
    
    record = @model_class.find_by(uuid: uuid)
    return [record, false] if record.nil?
    
    @backup = { attributes: record.attributes.dup }

    record.destroy
    [record, true]
  end
  
  def undo
    return false unless @backup
    
    @model_class.create(@backup[:attributes])
    true
  end
end