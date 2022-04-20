import TomSelect from "tom-select/dist/js/tom-select.complete"

const movements = {
  initialize() {
    const movement_select_options = {
      // maxItems: 1,
      valueField: 'id',
      labelField: 'name',
      searchField: 'name',
      sortField: 'name',
      create: function(input, callback) {
        $.ajax({
          type: "POST",
          url: "/movements",
          data: { movement: { name: input } },
          success: function(res) {
            if (res) {
              callback(res)
            }
          }
        })
      },
      load: function(query, callback) {
        $.getJSON("/movements.json", { query: query }, function(data) {
          callback(data)
        })
      }
    };

    $(document).on('turbo:load', function() {
      document.querySelectorAll('select.movement').forEach(select => {
        new TomSelect(select, movement_select_options)
      });

      $('#exercises').on('cocoon:after-insert', function(e, added_exercise) {
        added_exercise.find('select.movement').each(function(){
          new TomSelect(this, movement_select_options)
        })
      })
    })
  }
}

export default movements
