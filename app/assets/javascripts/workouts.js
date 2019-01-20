$(document).on('turbolinks:load', function() {
  $('#search').on({
    keyup: function() {
      $.get($('#search').attr('action'), $('#search').serialize(), null, 'script');
      return false;
    }
  });
});
