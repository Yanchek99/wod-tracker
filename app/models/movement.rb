class Movement < ApplicationRecord
  has_many :exercises, dependent: :destroy
  has_many :movement_logs, dependent: :destroy

  def self.search_by_name(name)
    return all unless name

    query = name.split(' ').reduce(nil) do |q, word|
      q.nil? ? arel_table[:name].matches("%#{word}%") : q.and(arel_table[:name].matches("%#{word}%"))
    end
    where(query)
  end
end
