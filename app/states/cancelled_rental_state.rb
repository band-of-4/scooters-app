class CancelledRentalState < RentalState
  def validate
  end

  def can_complete? = false
  def can_cancel?   = false

  def on_update?
    false
  end

  def on_delete?
    false
  end
end