import Foundation

struct SharedMemberInfo: Codable, Hashable {
    var name: String
    var amountPerCycle: Decimal
    var isOrganizer: Bool
}

struct SharedSubscriptionPayload: Codable, Hashable {
    static let currentVersion = 3

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
    var organizerName: String?
    var members: [SharedMemberInfo]?
    var recipientName: String?
}
