# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_16_110811) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "clients", force: :cascade do |t|
    t.decimal "balance", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.date "date_of_birth", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "patronymic"
    t.string "phone", null: false
    t.integer "total_rentals_count", default: 0, null: false
    t.decimal "total_spent", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_clients_on_email", unique: true
    t.index ["last_name"], name: "index_clients_on_last_name"
    t.index ["phone"], name: "index_clients_on_phone", unique: true
  end

  create_table "rentals", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.bigint "scooter_id", null: false
    t.datetime "start_time", null: false
    t.string "status", default: "active", null: false
    t.decimal "total_cost", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["client_id", "status"], name: "index_rentals_on_client_id_and_status"
    t.index ["client_id"], name: "index_rentals_on_client_id"
    t.index ["scooter_id", "status"], name: "index_rentals_on_scooter_id_and_status"
    t.index ["scooter_id", "status"], name: "index_rentals_on_scooter_id_when_active", unique: true, where: "((status)::text = 'active'::text)"
    t.index ["scooter_id"], name: "index_rentals_on_scooter_id"
    t.index ["start_time"], name: "index_rentals_on_start_time"
    t.index ["status"], name: "index_rentals_on_status"
  end

  create_table "scooters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "minute_rate", precision: 8, scale: 2, default: "5.0", null: false
    t.string "model", null: false
    t.string "serial_number", null: false
    t.string "status", default: "available", null: false
    t.datetime "updated_at", null: false
    t.index ["serial_number"], name: "index_scooters_on_serial_number", unique: true
    t.index ["status"], name: "index_scooters_on_status"
  end

  add_foreign_key "rentals", "clients"
  add_foreign_key "rentals", "scooters"
end
