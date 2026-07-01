json.extract! workout, :id, :name, :rounds, :time, :interval, :team_size, :created_at, :updated_at
json.url workout_url(workout, format: :json)
