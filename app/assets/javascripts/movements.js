$(document).on('turbolinks:load', function() {
  $('select.movement').selectize(movement_selectize_options);

  $('#exercises').on('cocoon:after-insert', function(e, added_exercise) {
    added_exercise.find('select.movement').selectize(movement_selectize_options);
  });
});

var movement_selectize_options = {
  maxItems: 1,
  valueField: 'id',
  labelField: 'name',
  searchField: 'name',
  sortField: 'name',
  create: function(input) {
    return $.ajax({
      type: "POST",
      url: "/movements",
      data: { movement: { name: input } },
      success: function(res) {
        return res;
      }
    });
  },
  load: function(query, callback) {
    $.getJSON("/movements.json", { query: query }, function(data) {
      callback(data);
    });
  }
};
