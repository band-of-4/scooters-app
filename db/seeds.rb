puts "Очистка существующих данных..."
Rental.delete_all
Client.delete_all
Scooter.delete_all

puts "Создание клиентов..."

clients = [
  {
    last_name: "Иванов",
    first_name: "Иван",
    patronymic: "Иванович",
    email: "ivanov@example.com",
    phone: "+79161234567",
    date_of_birth: Date.new(1990, 5, 15),
    balance: 1000.00,
    total_rentals_count: 0,
    total_spent: 0.00
  },
  {
    last_name: "Петрова",
    first_name: "Мария",
    patronymic: "Сергеевна",
    email: "petrova@example.com",
    phone: "+79162345678",
    date_of_birth: Date.new(1995, 8, 22),
    balance: 2500.50,
    total_rentals_count: 0,
    total_spent: 0.00
  },
  {
    last_name: "Сидоров",
    first_name: "Алексей",
    patronymic: "Петрович",
    email: "sidorov@example.com",
    phone: "+79163456789",
    date_of_birth: Date.new(1988, 3, 10),
    balance: 750.75,
    total_rentals_count: 0,
    total_spent: 0.00
  },
  {
    last_name: "Козлова",
    first_name: "Екатерина",
    patronymic: "Андреевна",
    email: "kozlova@example.com",
    phone: "+79164567890",
    date_of_birth: Date.new(1992, 11, 30),
    balance: 1500.00,
    total_rentals_count: 0,
    total_spent: 0.00
  },
  {
    last_name: "Николаев",
    first_name: "Дмитрий",
    patronymic: "Владимирович",
    email: "nikolaev@example.com",
    phone: "+79165678901",
    date_of_birth: Date.new(1985, 7, 5),
    balance: 500.25,
    total_rentals_count: 0,
    total_spent: 0.00
  }
]

clients.each do |client_attrs|
  Client.create!(client_attrs)
  puts "Создан клиент: #{client_attrs[:first_name]} #{client_attrs[:last_name]}"
end

puts "Создание самокатов..."

scooters = [
  {
    model: "Xiaomi Mi Pro 2",
    serial_number: "XM001234",
    status: "available",
    minute_rate: 5.00
  },
  {
    model: "Ninebot Max G30",
    serial_number: "NB005678",
    status: "available",
    minute_rate: 6.50
  },
  {
    model: "Kugoo Kirin M4",
    serial_number: "KG009012",
    status: "available",
    minute_rate: 4.75
  },
  {
    model: "Yandex Samokat",
    serial_number: "YD003456",
    status: "maintenance",
    minute_rate: 5.25
  },
  {
    model: "Ultron T1000",
    serial_number: "UL007890",
    status: "available",
    minute_rate: 7.00
  }
]

scooters.each do |scooter_attrs|
  Scooter.create!(scooter_attrs)
  puts "Создан самокат: #{scooter_attrs[:model]} (#{scooter_attrs[:serial_number]})"
end

puts "Создание аренд..."

# Получаем созданных клиентов и самокатов для ссылок
client1 = Client.find_by(email: "ivanov@example.com")
client2 = Client.find_by(email: "petrova@example.com")
client3 = Client.find_by(email: "sidorov@example.com")
client4 = Client.find_by(email: "kozlova@example.com")
client5 = Client.find_by(email: "nikolaev@example.com")

scooter1 = Scooter.find_by(serial_number: "XM001234")
scooter2 = Scooter.find_by(serial_number: "NB005678")
scooter3 = Scooter.find_by(serial_number: "KG009012")
scooter4 = Scooter.find_by(serial_number: "YD003456")
scooter5 = Scooter.find_by(serial_number: "UL007890")

rentals = [
  {
    client: client1,
    scooter: scooter1,
    start_time: 2.hours.ago,
    end_time: 1.hour.ago,
    status: "completed",
    total_cost: 300.00  # 5 руб/мин * 60 мин
  },
  {
    client: client2,
    scooter: scooter2,
    start_time: 3.hours.ago,
    end_time: 1.hour.ago,
    status: "completed",
    total_cost: 780.00  # 6.5 руб/мин * 120 мин
  },
  {
    client: client3,
    scooter: scooter3,
    start_time: 30.minutes.ago,
    end_time: nil,
    status: "active",
    total_cost: nil  # Будет рассчитано автоматически
  },
  {
    client: client4,
    scooter: scooter5,
    start_time: 1.day.ago,
    end_time: 23.hours.ago,
    status: "completed",
    total_cost: 420.00  # 7 руб/мин * 60 мин
  },
  {
    client: client5,
    scooter: scooter4,
    start_time: 2.days.ago,
    end_time: 1.day.ago + 2.hours,
    status: "cancelled",
    total_cost: 0.00
  }
]

rentals.each_with_index do |rental_attrs, index|
  rental = Rental.new(rental_attrs)
  
  # Для активной аренды устанавливаем end_time и рассчитываем стоимость
  if rental.status == "active" && rental.end_time.nil?
    rental.end_time = Time.current + 1.hour
  end
  
  rental.save!
  
  # Обновляем статистику клиента
  if rental.status == "completed" && rental.total_cost.to_f > 0
    rental.client.update(
      balance: rental.client.balance - rental.total_cost,
      total_spent: rental.client.total_spent + rental.total_cost,
      total_rentals_count: rental.client.total_rentals_count + 1
    )
  end
  
  puts "Создана аренда ##{index + 1}: #{rental.client.first_name} → #{rental.scooter.model}"
end

puts "Обновление статусов самокатов..."
# Обновляем статус самоката для активной аренды
active_rental = Rental.find_by(status: "active")
if active_rental
  active_rental.scooter.update(status: "rented")
  puts "Самокат #{active_rental.scooter.model} теперь в статусе 'rented'"
end

puts "=" * 50
puts "СИДЫ УСПЕШНО ВЫПОЛНЕНЫ!"
puts "=" * 50
puts "Создано:"
puts "  - Клиентов: #{Client.count}"
puts "  - Самокатов: #{Scooter.count}"
puts "  - Аренд: #{Rental.count}"
puts "=" * 50
puts "Статистика:"
puts "  - Активных аренд: #{Rental.where(status: 'active').count}"
puts "  - Завершенных аренд: #{Rental.where(status: 'completed').count}"
puts "  - Отмененных аренд: #{Rental.where(status: 'cancelled').count}"
puts "=" * 50