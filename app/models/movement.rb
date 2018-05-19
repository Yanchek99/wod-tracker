class Movement < ApplicationRecord
  belongs_to :measurement

  validates :measurement, presence: true
end
