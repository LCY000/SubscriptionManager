import Foundation

struct SharedSubscriptionPayload: Codable, Hashable {
    static let currentVersion = 1

    var version: Int = SharedSubscriptionPayload.currentVersion
    var name: String
    var amount: Decimal
    var currency: String
    var billingCycle: BillingCycle
    var firstPaymentDate: Date
    var brandColorHex: String
    var iconAssetName: String?
    var categoryName: String?
    var notes: String
    var suggestedShare: Decimal?
}
