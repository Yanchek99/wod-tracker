$(document).on('turbolinks:load', function() {
  $("select.metric").each(function(){
    unit_selectize = $(this).parent().find("select.unit").selectize(unit_selectize_options)[0].selectize;
    metric_selectize = $(this).selectize(metric_selectize_options(unit_selectize));
  });

  $('#exercises, #metrics').on('cocoon:after-insert', function(e, added_exercise) {
    unit_select = added_exercise.find('select.unit').selectize(unit_selectize_options)[0].selectize;
    added_exercise.find('select.metric').selectize(metric_selectize_options(unit_select));
  });
});

function metric_selectize_options(unit_selectize) {
  return {
    sortField: 'name',
    onChange: function() {
                metric_selectize = this;
                var items = unit_selectize.items
                unit_selectize.clear();
                unit_selectize.clearOptions();
                $.getJSON("/measurements/" + metric_selectize.getValue() + "/units.json", function(data) {
                  items = data.map(function(x) { return { name: x }; });
                  if (items.length === 0) {
                    unit_selectize.disable();
                  } else {
                    unit_selectize.addOption(items);
                    unit_selectize.addItem(items[0].name, true);
                    unit_selectize.enable();
                  }
                });
    					}
      }
};

var unit_selectize_options = {
  maxItems: 1,
  valueField: 'name',
  labelField: 'name',
  preload: true
};
