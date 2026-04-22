import jquery from 'jquery'
window.jQuery = jquery
window.$ = jquery

const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

if (csrfToken) {
  jquery.ajaxSetup({
    beforeSend(xhr, settings) {
      if (settings.type && !/^(GET|HEAD|OPTIONS|TRACE)$/i.test(settings.type)) {
        xhr.setRequestHeader('X-CSRF-Token', csrfToken)
      }
    }
  })
}
