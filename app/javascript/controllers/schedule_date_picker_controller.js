import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

// Connects to data-controller="schedule-date-picker"
export default class extends Controller {
  static values = { date: String, scheduled: Array }

  connect() {
    this.picker = flatpickr(this.element, {
      wrap: true,
      defaultDate: this.dateValue,
      dateFormat: "Y-m-d",
      onDayCreate: (_selectedDates, _dateStr, fp, dayElem) => {
        const date = fp.formatDate(dayElem.dateObj, "Y-m-d")
        if (this.scheduledValue.includes(date)) {
          dayElem.classList.add("has-schedule")
        }
      },
      onChange: (_selectedDates, dateStr) => {
        window.Turbo.visit(`${window.location.pathname}?date=${dateStr}`)
      }
    })
  }

  disconnect() {
    this.picker?.destroy()
  }
}
