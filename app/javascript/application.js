// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "trix"
import "@rails/actiontext"
import "./controllers"

import * as bootstrap from "bootstrap"
import LocalTime from "local-time"
import { dom, library } from "@fortawesome/fontawesome-svg-core"
import { faEdit } from "@fortawesome/free-solid-svg-icons/faEdit"
import { faExternalLinkAlt } from "@fortawesome/free-solid-svg-icons/faExternalLinkAlt"
import { faPlus } from "@fortawesome/free-solid-svg-icons/faPlus"
import { faTrashAlt } from "@fortawesome/free-solid-svg-icons/faTrashAlt"
import { faUser } from "@fortawesome/free-solid-svg-icons/faUser"
import { faCheckSquare } from "@fortawesome/free-regular-svg-icons/faCheckSquare"

LocalTime.start()
library.add(faCheckSquare, faEdit, faExternalLinkAlt, faPlus, faTrashAlt, faUser)
dom.watch()
