const font_awesome_extension = {
  initialize() {
    $(document).on('turbolinks:load', function() {
      FontAwesome.dom.i2svg();
    });

    $(document).on('cocoon:after-insert', function() {
      FontAwesome.dom.i2svg();
    });
  }
}

export default font_awesome_extension;
