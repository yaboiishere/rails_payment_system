import {Controller} from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
    connect() {
        // Auto-dismiss after 5 seconds
        this.dismissTimeout = setTimeout(() => {
            this.close()
        }, 5000)
    }

    disconnect() {
        if (this.dismissTimeout) {
            clearTimeout(this.dismissTimeout)
        }
    }

    close() {
        // Use Bootstrap's alert dismiss functionality
        const bsAlert = bootstrap.Alert.getOrCreateInstance(this.element)
        bsAlert.close()
    }
}