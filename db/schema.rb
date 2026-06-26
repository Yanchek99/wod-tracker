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

ActiveRecord::Schema[8.1].define(version: 2026_06_26_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "exercises", force: :cascade do |t|
    t.integer "calories"
    t.datetime "created_at", precision: nil, null: false
    t.integer "distance"
    t.integer "distance_unit"
    t.integer "distance_units_per_rep"
    t.integer "duration_seconds"
    t.integer "female_calories"
    t.integer "female_distance"
    t.integer "female_load"
    t.integer "implement_count"
    t.integer "ladder_step_every"
    t.integer "load"
    t.integer "load_unit"
    t.integer "male_calories"
    t.integer "male_distance"
    t.integer "male_load"
    t.bigint "movement_id"
    t.string "notes"
    t.integer "position", null: false
    t.integer "reps"
    t.bigint "segment_id"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "workout_id"
    t.index ["movement_id"], name: "index_exercises_on_movement_id"
    t.index ["position", "segment_id"], name: "index_exercises_on_position_and_segment_id", unique: true, where: "(segment_id IS NOT NULL)"
    t.index ["position", "workout_id"], name: "index_exercises_on_position_and_workout_id", unique: true, where: "(segment_id IS NULL)"
    t.index ["segment_id"], name: "index_exercises_on_segment_id"
    t.index ["workout_id"], name: "index_exercises_on_workout_id"
  end

  create_table "logs", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "reps_per_round"
    t.integer "score_type", null: false
    t.integer "score_value"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.bigint "workout_id"
    t.index ["user_id"], name: "index_logs_on_user_id"
    t.index ["workout_id"], name: "index_logs_on_workout_id"
  end

  create_table "movement_logs", force: :cascade do |t|
    t.integer "calories"
    t.datetime "created_at", precision: nil, null: false
    t.integer "distance"
    t.integer "distance_unit"
    t.integer "duration_seconds"
    t.integer "implement_count"
    t.integer "load"
    t.integer "load_unit"
    t.bigint "log_id"
    t.bigint "movement_id"
    t.string "notes"
    t.integer "reps"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["log_id"], name: "index_movement_logs_on_log_id"
    t.index ["movement_id"], name: "index_movement_logs_on_movement_id"
  end

  create_table "movements", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_movements_on_name", unique: true
  end

  create_table "programs", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "posted_at", precision: nil, null: false
    t.bigint "program_id"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "workout_id"
    t.index ["posted_at"], name: "index_schedules_on_posted_at"
    t.index ["program_id", "posted_at"], name: "index_schedules_on_program_id_and_posted_at"
    t.index ["program_id"], name: "index_schedules_on_program_id"
    t.index ["workout_id"], name: "index_schedules_on_workout_id"
  end

  create_table "segments", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "interval_scheme"
    t.string "name"
    t.text "notes"
    t.integer "position", null: false
    t.integer "rest_seconds"
    t.integer "rounds"
    t.integer "time_seconds"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "workout_id"
    t.index ["position", "workout_id"], name: "index_segments_on_position_and_workout_id", unique: true
    t.index ["workout_id"], name: "index_segments_on_workout_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.bigint "program_id"
    t.integer "role"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["program_id", "user_id"], name: "index_subscriptions_on_program_id_and_user_id", unique: true
    t.index ["program_id"], name: "index_subscriptions_on_program_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "role"
    t.integer "sex", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "weight"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workouts", force: :cascade do |t|
    t.string "content_key"
    t.datetime "created_at", precision: nil, null: false
    t.string "interval"
    t.integer "ladder_start"
    t.integer "ladder_step"
    t.string "name"
    t.integer "rounds"
    t.integer "score_type", null: false
    t.integer "time"
    t.integer "time_cap_seconds"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["content_key"], name: "index_workouts_on_content_key", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "exercises", "movements"
  add_foreign_key "exercises", "segments"
  add_foreign_key "exercises", "workouts"
  add_foreign_key "movement_logs", "logs"
  add_foreign_key "movement_logs", "movements"
  add_foreign_key "schedules", "programs"
  add_foreign_key "schedules", "workouts"
  add_foreign_key "segments", "workouts"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "subscriptions", "programs"
  add_foreign_key "subscriptions", "users"
end
