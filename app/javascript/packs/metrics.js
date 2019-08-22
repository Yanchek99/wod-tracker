const metrics = {
  initialize() {
    const metric_selectize_options = {
      sortField: 'name'
    };

    $("select.metric").selectize(metric_selectize_options);

    $('#exercises, #metrics').on('cocoon:after-insert', function(e, added_exercise) {
      added_exercise.find('select.metric').selectize(metric_selectize_options);
    });
  }
};

export default metrics;
