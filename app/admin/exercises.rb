ActiveAdmin.register Exercise do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :workout_id, :movement_id, :segment_id, :position, :repitions, :load_unit, :load, :distance_unit, :distance, :time
  #
  # or
  #
  # permit_params do
  #   permitted = [:workout_id, :movement_id, :segment_id, :position, :repitions, :load_unit, :load, :distance_unit, :distance, :time]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
