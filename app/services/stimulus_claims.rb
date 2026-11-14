# Published stimulus claims for seeded workouts (config/stimulus_claims.yml), which
# StimulusAccuracy checks the calculator against: a result or finish window, round time, rounds
# target, working-set percentage, and per-movement loading, sets guide and time ceiling.
# `propose` drafts claims from CrossFit's posted text with regular expressions (no LLM).
module StimulusClaims
  PATH = Rails.root.join('config/stimulus_claims.yml')

  # source: open_leaderboard, benchmark_page, hero_page, guide (L1/L2 training guides), or
  # crossfit_text (CrossFit's posted text on a seeded workout, e.g. a reposted benchmark). Every
  # claim names a seeded workout, so the check runs in any seeded environment.
  Claim = Data.define(:workout_name, :claims, :source, :reviewed)

  module_function

  def load(path = PATH)
    entries(path).map do |entry|
      Claim.new(workout_name: entry.fetch('workout'), claims: entry.fetch('claims', {}), source: entry['source'],
                reviewed: entry['reviewed'])
    end
  end

  # Every workout name the seeds create (benchmarks, Heroes, Open, CrossFit.com).
  def seeded_workout_names
    @seeded_workout_names ||= Rails.root.glob('db/seeds/*.rb').flat_map do |path|
      path.read.scan(/find_or_create_by\(name: '([^']+)'\)/)
    end.flatten
  end

  def entries(path = PATH)
    YAML.safe_load_file(path).fetch('claims', [])
  end

  # Rewrites the claims file, keeping its header comment.
  def write(entries, path = PATH)
    header = File.read(path)[/\A(?:#.*\n)*/]
    File.write(path, header + { 'claims' => entries }.to_yaml(line_width: 110).delete_prefix("---\n"))
  end

  # Claims a text makes, keyed by claim name; movement_names are the workout's movements.
  def propose(text, movement_names) = Proposer.call(text, movement_names)
end
