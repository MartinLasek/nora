import Foundation

extension Int {
    func dotNotation() -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: self), number: NumberFormatter.Style.decimal)
    }
}
