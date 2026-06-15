class MovementLog < ApplicationRecord
  belongs_to :log
  belongs_to :movement
  has_many :metrics, as: :measurable, dependent: :destroy

  default_scope { includes(:metrics) }

  accepts_nested_attributes_for :metrics, allow_destroy: true

  # Movement logs record actual performance as metrics; they share the prescription-rendering
  # helpers with Exercise, which read this collection.
  def prescription_metrics
    metrics.to_a
  end
end
