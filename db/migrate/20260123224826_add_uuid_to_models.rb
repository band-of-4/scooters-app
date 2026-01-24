class AddUuidToModels < ActiveRecord::Migration[8.1]
  def change
    add_column :scooters, :uuid, :uuid, default: -> { "gen_random_uuid()" }, null: false
    add_column :clients, :uuid, :uuid, default: -> { "gen_random_uuid()" }, null: false
    add_column :rentals, :uuid, :uuid, default: -> { "gen_random_uuid()" }, null: false
    
    add_index :scooters, :uuid, unique: true
    add_index :clients, :uuid, unique: true
    add_index :rentals, :uuid, unique: true
  end
end
