class CreateSolidQueueTables < ActiveRecord::Migration[8.1]
  def change
    create_table :solid_queue_jobs do |t|
      t.string :queue_name, null: false
      t.string :class_name, null: false
      t.text :arguments
      t.integer :priority, default: 0, null: false
      t.string :active_job_id
      t.datetime :scheduled_at
      t.datetime :finished_at
      t.string :concurrency_key
      t.timestamps

      t.index [:active_job_id], name: 'index_solid_queue_jobs_on_active_job_id'
      t.index [:class_name], name: 'index_solid_queue_jobs_on_class_name'
      t.index [:finished_at], name: 'index_solid_queue_jobs_on_finished_at'
      t.index %i[queue_name finished_at], name: 'index_solid_queue_jobs_for_filtering'
      t.index %i[scheduled_at finished_at], name: 'index_solid_queue_jobs_for_alerting'
    end

    create_table :solid_queue_scheduled_executions do |t|
      t.references :job, null: false, index: { unique: true }
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.datetime :scheduled_at, null: false
      t.datetime :created_at, null: false

      t.index %i[scheduled_at priority job_id], name: 'index_solid_queue_dispatch_all'
    end

    create_table :solid_queue_ready_executions do |t|
      t.references :job, null: false, index: { unique: true }
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.datetime :created_at, null: false

      t.index %i[priority job_id], name: 'index_solid_queue_poll_all'
      t.index %i[queue_name priority job_id], name: 'index_solid_queue_poll_by_queue'
    end

    create_table :solid_queue_claimed_executions do |t|
      t.references :job, null: false, index: { unique: true }
      t.bigint :process_id
      t.datetime :created_at, null: false

      t.index %i[process_id job_id], name: 'index_solid_queue_claimed_executions_on_process_id_and_job_id'
    end

    create_table :solid_queue_blocked_executions do |t|
      t.references :job, null: false, index: { unique: true }
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.string :concurrency_key, null: false
      t.datetime :expires_at, null: false
      t.datetime :created_at, null: false

      t.index %i[expires_at concurrency_key], name: 'index_solid_queue_blocked_executions_for_maintenance'
      t.index %i[concurrency_key priority job_id], name: 'index_solid_queue_blocked_executions_for_release'
    end

    create_table :solid_queue_failed_executions do |t|
      t.references :job, null: false, index: { unique: true }
      t.text :error
      t.datetime :created_at, null: false
    end

    create_table :solid_queue_pauses do |t|
      t.string :queue_name, null: false, index: { unique: true }
      t.datetime :created_at, null: false
    end

    create_table :solid_queue_processes do |t|
      t.string :kind, null: false
      t.datetime :last_heartbeat_at, null: false
      t.bigint :supervisor_id, index: true
      t.integer :pid, null: false
      t.string :hostname
      t.text :metadata
      t.datetime :created_at, null: false
      t.string :name, null: false

      t.index [:last_heartbeat_at], name: 'index_solid_queue_processes_on_last_heartbeat_at'
      t.index %i[name supervisor_id], name: 'index_solid_queue_processes_on_name_and_supervisor_id', unique: true
    end

    create_table :solid_queue_semaphores do |t|
      t.string :key, null: false, index: { unique: true }
      t.integer :value, default: 1, null: false
      t.datetime :expires_at, null: false
      t.timestamps

      t.index [:expires_at], name: 'index_solid_queue_semaphores_on_expires_at'
      t.index %i[key value], name: 'index_solid_queue_semaphores_on_key_and_value'
    end

    create_table :solid_queue_recurring_executions do |t|
      t.references :job, null: false, index: { unique: true }
      t.string :task_key, null: false
      t.datetime :run_at, null: false
      t.datetime :created_at, null: false

      t.index %i[task_key run_at], name: 'index_solid_queue_recurring_executions_on_task_key_and_run_at', unique: true
    end

    create_table :solid_queue_recurring_tasks do |t|
      t.string :key, null: false, index: { unique: true }
      t.string :schedule, null: false
      t.string :command, limit: 2048
      t.string :class_name
      t.text :arguments
      t.string :queue_name
      t.integer :priority, default: 0
      t.boolean :static, default: true, null: false, index: true
      t.text :description
      t.timestamps
    end

    add_foreign_key :solid_queue_blocked_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
    add_foreign_key :solid_queue_claimed_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
    add_foreign_key :solid_queue_failed_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
    add_foreign_key :solid_queue_ready_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
    add_foreign_key :solid_queue_recurring_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
    add_foreign_key :solid_queue_scheduled_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
  end
end
