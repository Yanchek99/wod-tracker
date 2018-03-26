class Movement < ApplicationRecord
  enum measurement: [:weight, :distance, :time, :height]
end
