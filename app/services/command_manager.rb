class CommandManager
  def initialize(model_class, session_id)
    @session_id = session_id
    @model_class = model_class

    @undo_key = "class:#{@model_class}:undo:#{session_id}"
    @redo_key = "class:#{@model_class}:redo:#{session_id}"
  end

  def execute(command)
    record, success = command.execute

    if success
      save_command(command, @undo_key)
      clear_redo
    end

    [record, success]
  end

  def undo
    command_data = pop_command(@undo_key)
    return false unless command_data

    command = BaseCommand.deserialize(command_data)

    if command.undo
      save_command(command, @redo_key)
      true
    else
      false
    end
  end

  def redo
    command_data = pop_command(@redo_key)
    return false unless command_data

    command = BaseCommand.deserialize(command_data)
    record, success = command.execute

    if success
      save_command(command, @undo_key)
      true
    else
      false
    end
  end

  private

  def save_command(command, key)
    $redis.lpush(key, command.serialize.to_json)
    $redis.ltrim(key, 0, 9)
  end

  def pop_command(key)
    json = $redis.lpop(key)
    puts json
    return nil unless json

    JSON.parse(json, symbolize_names: true)
  end

  def clear_redo
    $redis.del(@redo_key)
  end
end