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

ActiveRecord::Schema[8.0].define(version: 2025_06_27_191715) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "transactions", force: :cascade do |t|
    t.string "uuid"
    t.decimal "amount"
    t.integer "status"
    t.string "customer_email"
    t.string "customer_phone"
    t.bigint "merchant_id", null: false
    t.bigint "parent_transaction_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_transactions_on_merchant_id"
    t.index ["parent_transaction_id"], name: "index_transactions_on_parent_transaction_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "email"
    t.integer "status"
    t.decimal "total_transaction_sum"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "transactions", "transactions", column: "parent_transaction_id"
  add_foreign_key "transactions", "users", column: "merchant_id"
end
