class ActiveRentalState < RentalState
  def on_update?
    true
  end

  def on_delete?
    true
  end
end