class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.string :last_name, null: false
      t.string :first_name, null: false
      t.string :patronymic
      t.string :email, null: false
      t.string :phone, null: false
      t.date :date_of_birth, null: false
      t.integer :total_rentals_count, null: false, default: 0
      t.decimal :total_spent, null: false, precision: 10, scale: 2, default: 0.0
      t.decimal :balance, null: false, precision: 10, scale: 2, default: 0.0

      t.timestamps
    end

    add_index :clients, :email, unique: true
    add_index :clients, :phone, unique: true
    add_index :clients, :last_name
  end
end
