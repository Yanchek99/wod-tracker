import TomSelect from "tom-select"

const metric_select_options = {
  sortField: 'name'
}

function initializeMetricSelect(select) {
  if (select.tomselect) return

  new TomSelect(select, metric_select_options)
}

const metrics = {
  initialize(root = document) {
    root.querySelectorAll('select.metric').forEach(initializeMetricSelect)
  },

  bind() {
    $(document).off('cocoon:after-insert.tom-select-metrics', '#exercises, #metrics')
    $(document).on('cocoon:after-insert.tom-select-metrics', '#exercises, #metrics', function(e, added_exercise) {
      added_exercise.find('select.metric').each(function() {
        initializeMetricSelect(this)
      })
    })
  }
}

export default metrics
