$(document).on('turbolinks:load', function() {
  FontAwesome.dom.i2svg();
});

$(document).on('cocoon:after-insert', function() {
  FontAwesome.dom.i2svg();
});
