class CreateScooters < ActiveRecord::Migration[8.1]
  def change
    create_table :scooters do |t|
      t.string :model, null: false
      t.string :serial_number, null: false
      t.string :status, null: false, default: 'avaliable'
      t.decimal :minute_rate, null: false, precision: 8, scale: 2, default: 5.0

      t.timestamps
    end

    add_index :scooters, :serial_number, unique: true
    add_index :scooters, :status
  end
end
