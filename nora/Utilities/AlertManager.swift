import UIKit

final class AlertManager {

    static func uniqueName() -> UIAlertController {
        let uniqueAlert = UIAlertController(title: "Name must be unique!", message: nil, preferredStyle: .alert)
        uniqueAlert.addAction(UIAlertAction(title: "Ok", style: .default))
        return uniqueAlert
    }

    static func textFieldValue(from alert: UIAlertController?) -> String {

        guard
            let alert = alert,
            let textFields = alert.textFields,
            !textFields.isEmpty,
            let value = textFields[0].text
        else {
            return ""
        }

        return value
    }
}
