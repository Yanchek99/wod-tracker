$(document).on('turbolinks:load', function() {
  $('#exercises').on('cocoon:after-insert', function(e, added_exercise) {
    added_exercise.find("input[name*='position']").val($('.exercise').length);
  });
});
