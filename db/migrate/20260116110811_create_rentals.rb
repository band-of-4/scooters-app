class CreateRentals < ActiveRecord::Migration[8.1]
  def change
    create_table :rentals do |t|
      t.references :scooter, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.decimal :total_cost, precision: 10, scale: 2
      t.string :status, null: false, default: 'active'

      t.timestamps
    end

    add_index :rentals, :status
    add_index :rentals, :start_time
    add_index :rentals, [:scooter_id, :status]
    add_index :rentals, [:client_id, :status]
    
    add_index :rentals, [:scooter_id, :status], 
        where: "status = 'active'",
        unique: true,
        name: 'index_rentals_on_scooter_id_when_active'
  end
end
