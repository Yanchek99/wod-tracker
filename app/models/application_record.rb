class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def updated?
    updated_at > created_at
  end
end
