import TomSelect from "tom-select"

const movement_select_options = {
  // maxItems: 1,
  valueField: 'id',
  labelField: 'name',
  searchField: 'name',
  sortField: 'name',
  create: function(input, callback) {
    const name = input.trim()

    if (!name) {
      callback()
      return
    }

    $.ajax({
      type: "POST",
      url: "/movements",
      dataType: "json",
      data: { movement: { name: name } },
      success: function(res) {
        if (res) {
          callback(res)
        }
      },
      error: function(xhr) {
        console.error("Failed to create movement", xhr.responseJSON || xhr.responseText)
        callback()
      }
    })
  },
  load: function(query, callback) {
    $.getJSON("/movements.json", { query: query }, function(data) {
      callback(data)
    })
  }
}

function initializeMovementSelect(select) {
  if (select.tomselect) return

  new TomSelect(select, movement_select_options)
}

const movements = {
  initialize(root = document) {
    root.querySelectorAll('select.movement').forEach(initializeMovementSelect)
  },

  bind() {
    $(document).off('cocoon:after-insert.tom-select-movements', '#exercises')
    $(document).on('cocoon:after-insert.tom-select-movements', '#exercises', function(e, added_exercise) {
      added_exercise.find('select.movement').each(function() {
        initializeMovementSelect(this)
      })
    })
  }
}

export default movements
