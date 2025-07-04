// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "./controllers"
import "@hotwired/turbo-rails"
import LocalTime from "local-time"

LocalTime.start()
document.addEventListener("turbo:morph", () => {
    LocalTime.run()
})
