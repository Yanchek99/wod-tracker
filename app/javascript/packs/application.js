// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("bootstrap/dist/js/bootstrap")
require("selectize/dist/js/standalone/selectize")
require("jquery")
require("@nathanvda/cocoon")

import LocalTime from "local-time"

import font_awesome_extension from './font-awesome'
import workout_search from './workout_search'
import exercise from './exercise'
import metrics from './metrics'
import movements from './movements'
import logs from './logs'

LocalTime.start()
font_awesome_extension.initialize()
movements.initialize()
logs.initialize()

document.addEventListener("turbolinks:load", () => {
  $('select').selectize()
  workout_search.initialize()
  exercise.initialize()
  metrics.initialize()

  $.ajaxSetup({
    headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') }
  })
})



// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
