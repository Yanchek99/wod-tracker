class Movement < ApplicationRecord
  has_many :exercises, dependent: :destroy
  has_many :movement_logs, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.search_by_name(name)
    return all unless name

    query = name.split(' ').reduce(nil) do |q, word|
      q.nil? ? arel_table[:name].matches("%#{word}%") : q.and(arel_table[:name].matches("%#{word}%"))
    end
    where(query)
  end
end
