# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_26_032340) do

  create_table "auths", force: :cascade do |t|
    t.text "auth_token"
    t.text "refresh_token"
    t.datetime "auth_token_exp"
    t.datetime "refresh_token_exp"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "queries", force: :cascade do |t|
    t.text "symbols"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "spreads", force: :cascade do |t|
    t.string "sym"
    t.string "year_week"
    t.string "strike_5"
    t.string "strike_4"
    t.string "strike_3"
    t.string "strike_2"
    t.decimal "underlying_m"
    t.decimal "five_three_val_m"
    t.decimal "four_three_val_m"
    t.decimal "three_two_val_m"
    t.decimal "underlying_t"
    t.decimal "five_three_val_t"
    t.decimal "four_three_val_t"
    t.decimal "three_two_val_t"
    t.decimal "underlying_w"
    t.decimal "five_three_val_w"
    t.decimal "four_three_val_w"
    t.decimal "three_two_val_w"
    t.decimal "underlying_th"
    t.decimal "five_three_val_th"
    t.decimal "four_three_val_th"
    t.decimal "three_two_val_th"
    t.decimal "underlying_f"
    t.decimal "five_three_val_f"
    t.decimal "four_three_val_f"
    t.decimal "three_two_val_f"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
