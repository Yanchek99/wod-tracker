json.extract! workout, :id, :name, :rounds, :time, :interval, :created_at, :updated_at
json.url workout_url(workout, format: :json)
