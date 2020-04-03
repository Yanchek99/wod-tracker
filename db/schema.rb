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

ActiveRecord::Schema.define(version: 2020_04_03_033141) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "exercises", force: :cascade do |t|
    t.bigint "workout_id"
    t.bigint "movement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "segment_id"
    t.integer "position"
    t.index ["movement_id"], name: "index_exercises_on_movement_id"
    t.index ["position", "workout_id"], name: "index_exercises_on_position_and_workout_id", unique: true
    t.index ["segment_id"], name: "index_exercises_on_segment_id"
    t.index ["workout_id"], name: "index_exercises_on_workout_id"
  end

  create_table "logs", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "workout_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_logs_on_user_id"
    t.index ["workout_id"], name: "index_logs_on_workout_id"
  end

  create_table "metrics", force: :cascade do |t|
    t.string "measurable_type"
    t.bigint "measurable_id"
    t.string "measurement", null: false
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["measurable_type", "measurable_id"], name: "index_metrics_on_measurable_type_and_measurable_id"
  end

  create_table "movement_logs", force: :cascade do |t|
    t.bigint "log_id"
    t.bigint "movement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["log_id"], name: "index_movement_logs_on_log_id"
    t.index ["movement_id"], name: "index_movement_logs_on_movement_id"
  end

  create_table "movements", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_movements_on_name", unique: true
  end

  create_table "programs", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "schedules", force: :cascade do |t|
    t.bigint "program_id"
    t.bigint "workout_id"
    t.datetime "posted_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["program_id"], name: "index_schedules_on_program_id"
    t.index ["workout_id"], name: "index_schedules_on_workout_id"
  end

  create_table "segments", force: :cascade do |t|
    t.bigint "workout_id"
    t.integer "rounds"
    t.integer "time"
    t.integer "interval"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workout_id"], name: "index_segments_on_workout_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "program_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "athlete"
    t.index ["program_id", "user_id"], name: "index_subscriptions_on_program_id_and_user_id", unique: true
    t.index ["program_id"], name: "index_subscriptions_on_program_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "athlete", null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "weight"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workouts", force: :cascade do |t|
    t.string "name"
    t.integer "rounds"
    t.integer "time"
    t.string "interval"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.integer "time_cap_seconds"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "exercises", "movements"
  add_foreign_key "exercises", "segments"
  add_foreign_key "exercises", "workouts"
  add_foreign_key "movement_logs", "logs"
  add_foreign_key "movement_logs", "movements"
  add_foreign_key "schedules", "programs"
  add_foreign_key "schedules", "workouts"
  add_foreign_key "segments", "workouts"
  add_foreign_key "subscriptions", "programs"
  add_foreign_key "subscriptions", "users"
end
