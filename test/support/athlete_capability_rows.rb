# Builds an AthleteCapability for tests. mathew has no capability fixtures, so these rows never
# collide with the fixture data.
module AthleteCapabilityRows
  private

  def build_row(kind:, **attrs)
    AthleteCapability.new(
      { user: users(:mathew), movement: movements(:run), source: :heuristic, model_version: 'heuristic-v1',
        computed_at: Time.current, kind: kind }.merge(attrs)
    )
  end
end
