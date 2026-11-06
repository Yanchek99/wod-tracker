module ProgramsHelper
  ROLE_LABELS = { 'owner' => 'Owner', 'coach' => 'Coach', 'athlete' => 'Athlete' }.freeze

  # Non-interactive pill showing the user's role on a program they follow.
  def role_pill(role)
    return if role.blank?

    content_tag(:span, ROLE_LABELS.fetch(role.to_s, role.to_s.titleize), class: "role-pill role-pill--#{role}")
  end

  def unfollow_confirm_message(program)
    "Unfollow #{program.name}? It will leave your Programs list and stop appearing on your schedule."
  end

  def delete_confirm_message(program, workouts:, followers:)
    "Delete #{program.name}? This also deletes its #{pluralize(workouts, 'scheduled workout')} and removes it " \
      "for its #{pluralize(followers, 'follower')}. This can't be undone."
  end
end
