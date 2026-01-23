class ActiveRentalState < RentalState
  def validate
    rental.errors.add(:scooter, 'не доступен') if rental.scooter&.status != 'available'
  end

  def on_update?
    true
  end

  def on_delete?
    true
  end
end