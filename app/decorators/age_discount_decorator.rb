class AgeDiscountDecorator < ClientDecorator
  def discount_multiplier
    return 1.0 unless eligible_for_discount?

    0.8
  end

  private

  def eligible_for_discount?
    puts age
    age >= 65
  end


  def age
    today = Date.current
    age = today.year - @client.date_of_birth.year

    if today < @client.date_of_birth + age.years
      age -= 1
    end

    age
  end
end
