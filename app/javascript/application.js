// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

import * as bootstrap from "bootstrap"
import LocalTime from "local-time"
import "@fortawesome/fontawesome-free/js/all"
import "tom-select/dist/js/tom-select.complete"

import "./jquery"
import "@nathanvda/cocoon" // REQUIRES JQUERY

import logs from './logs'
import metrics from './metrics'
import movements from './movements'

LocalTime.start()
logs.initialize()
movements.initialize()

document.addEventListener("turbo:load", () => {
  metrics.initialize()

  $('#exercises').on('cocoon:after-insert', function(e, added_exercise) {
    added_exercise.find("input[name*='position']").val($('.exercise').length)
  })
});

import "trix"
import "@rails/actiontext"
