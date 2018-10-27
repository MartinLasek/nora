import Foundation
import StoreKit

// Manages the count of how often the app was launched
// and decides whether it's time to ask for a review
struct AppVisitManager {
    static let userDefaultKey = "app_visit_count"
    static let requiredOpenCount = 23
    static let storage = UserDefaults.standard

    static func checkAndAskForReview() {
        let count = visitCount()

        switch count {
        case _ where count%requiredOpenCount == 0:
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        default:
            break
        }
    }

    static func visitCount() -> Int {
        if let appVisitCount = storage.value(forKey: AppVisitManager.userDefaultKey) as? Int {
            return appVisitCount
        }
        return 0
    }

    static func increaseVisitCount() {
        let count = visitCount()
        let newCount = count + 1
        storage.set(newCount, forKey: AppVisitManager.userDefaultKey)
    }
}
