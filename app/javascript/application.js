// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

import * as bootstrap from "bootstrap"
import LocalTime from "local-time"
import "@fortawesome/fontawesome-free/js/all"
import "./jquery"
import "@nathanvda/cocoon" // REQUIRES JQUERY

import logs from './logs'
import metrics from './metrics'
import movements from './movements'

LocalTime.start()
logs.initialize()
movements.bind()
metrics.bind()

document.addEventListener("turbo:load", () => {
  movements.initialize()
  metrics.initialize()

  $('#exercises').on('cocoon:after-insert', function(e, added_exercise) {
    added_exercise.find("input[name*='position']").val($('.exercise').length)
  })
});
