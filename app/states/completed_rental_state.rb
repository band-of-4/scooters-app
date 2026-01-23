class CompletedRentalState < RentalState
  def validate
    rental.errors.add(:end_time, 'обязательно для completed') if rental.end_time.blank?
    rental.errors.add(:end_time, 'должно быть позже начала') if rental.end_time <= rental.start_time
  end

  def on_update?
    false
  end

  def on_delete?
    false
  end

  def can_complete? = false
  def can_cancel?   = false
end