const workout_search = {
  initialize() {
    $('#search').on({
      keyup: function() {
        $.get($('#search').attr('action'), $('#search').serialize(), null, 'script');
        return false;
      }
    })
  }
};

export default workout_search;
