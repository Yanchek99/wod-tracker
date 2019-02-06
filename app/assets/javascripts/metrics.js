$(document).on('turbolinks:load', function() {
  $("select.metric").selectize(metric_selectize_options);

  $('#exercises, #metrics').on('cocoon:after-insert', function(e, added_exercise) {
    added_exercise.find('select.metric').selectize(metric_selectize_options);
  });
});

var metric_selectize_options = {
  sortField: 'name'
};
