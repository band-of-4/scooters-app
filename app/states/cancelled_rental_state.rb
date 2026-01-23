class CancelledRentalState < RentalState
  def on_update?
    false
  end

  def on_delete?
    false
  end
end