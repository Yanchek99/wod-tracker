module NavigationHelper
  NavItem = Data.define(:key, :label, :short_label, :icon, :path, :group)

  # Destinations for the sidebar and phone tab bar. Schedule is hidden for users who have none.
  def nav_items
    items = []
    items << NavItem.new(:schedules, 'Schedule', 'Schedule', :calendar, schedules_path, nil) unless Current.user.schedules.empty?
    items << NavItem.new(:workouts, 'Workouts', 'Workouts', :dumbbell, workouts_path, nil)
    items << NavItem.new(:programs, 'Programs', 'Programs', :clipboard_list, programs_path, nil)
    items << NavItem.new(:personal_records, 'Personal records', 'PRs', :trophy,
                         family_user_personal_records_path(Current.user, family: 'weightlifting'), :progress)
    items << NavItem.new(:logs, 'History', 'History', :history, logs_path, :progress)
  end

  def nav_active?(item)
    controller_name.to_sym == item.key
  end
end
