# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_02_26_052333) do

  create_table "exercises", force: :cascade do |t|
    t.integer "workout_id"
    t.integer "movement_id"
    t.integer "reps"
    t.string "measurement"
    t.string "measurement_value"
    t.integer "male_rx"
    t.integer "female_rx"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movement_id"], name: "index_exercises_on_movement_id"
    t.index ["workout_id"], name: "index_exercises_on_workout_id"
  end

  create_table "logs", force: :cascade do |t|
    t.integer "workout_id"
    t.string "measurement_value"
    t.integer "measurement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workout_id"], name: "index_logs_on_workout_id"
  end

  create_table "movements", force: :cascade do |t|
    t.string "name"
    t.integer "measurement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workouts", force: :cascade do |t|
    t.string "name"
    t.integer "rounds"
    t.integer "time"
    t.string "interval"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
