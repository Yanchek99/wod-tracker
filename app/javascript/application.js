// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "trix"
import "@rails/actiontext"
import "./controllers"

import * as bootstrap from "bootstrap"
import LocalTime from "local-time"
import { dom, library } from "@fortawesome/fontawesome-svg-core"
import { faCircleInfo } from "@fortawesome/free-solid-svg-icons/faCircleInfo"
import { faEdit } from "@fortawesome/free-solid-svg-icons/faEdit"
import { faExternalLinkAlt } from "@fortawesome/free-solid-svg-icons/faExternalLinkAlt"
import { faDumbbell } from "@fortawesome/free-solid-svg-icons/faDumbbell"
import { faFloppyDisk } from "@fortawesome/free-solid-svg-icons/faFloppyDisk"
import { faGripVertical } from "@fortawesome/free-solid-svg-icons/faGripVertical"
import { faLayerGroup } from "@fortawesome/free-solid-svg-icons/faLayerGroup"
import { faPlus } from "@fortawesome/free-solid-svg-icons/faPlus"
import { faTrashAlt } from "@fortawesome/free-solid-svg-icons/faTrashAlt"
import { faUser } from "@fortawesome/free-solid-svg-icons/faUser"
import { faXmark } from "@fortawesome/free-solid-svg-icons/faXmark"
import { faCheckSquare } from "@fortawesome/free-regular-svg-icons/faCheckSquare"

LocalTime.start()
library.add(
  faCheckSquare,
  faCircleInfo,
  faDumbbell,
  faEdit,
  faExternalLinkAlt,
  faFloppyDisk,
  faGripVertical,
  faLayerGroup,
  faPlus,
  faTrashAlt,
  faUser,
  faXmark
)
dom.watch()
