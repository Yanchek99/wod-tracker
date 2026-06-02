// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

import * as bootstrap from "bootstrap"
import LocalTime from "local-time"
import "@fortawesome/fontawesome-free/js/all"
import "./jquery"
import "@nathanvda/cocoon" // REQUIRES JQUERY

LocalTime.start()
