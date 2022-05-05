import TomSelect from "tom-select/dist/js/tom-select.complete"

const metrics = {
  initialize() {
    const metric_select_options = {
      sortField: 'name'
    }

    document.querySelectorAll('select.metric').forEach(select => {
    	new TomSelect(select, metric_select_options);
    });

    $('#exercises, #metrics').on('cocoon:after-insert', function(e, added_exercise) {
      added_exercise.find('select.metric').each(function() {
        new TomSelect(this, metric_select_options);
      })
    })
  }
}

export default metrics
