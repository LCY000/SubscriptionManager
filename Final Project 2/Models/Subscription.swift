import Foundation
import SwiftData

@Model
final class Subscription {
    var id: UUID = UUID()
    var name: String = ""
    var iconAssetName: String?
    var brandColorHex: String = "#8E8E93"
    var amount: Decimal = Decimal.zero
    var currency: String = "TWD"
    var billingCycle: BillingCycle = BillingCycle.monthly
    var firstPaymentDate: Date = Date()
    var status: SubscriptionStatus = SubscriptionStatus.active
    var trialEndDate: Date?
    var notes: String = ""
    var reminderDaysBefore: Int = 1
    var isShared: Bool = false
    var isOrganizer: Bool = true
    var myShareOverride: Decimal?
    var createdAt: Date = Date()

    @Relationship(deleteRule: .nullify, inverse: \SubscriptionCategory.subscriptions)
    var category: SubscriptionCategory?

    @Relationship(deleteRule: .cascade, inverse: \PaymentRecord.subscription)
    var paymentRecords: [PaymentRecord] = []

    @Relationship(deleteRule: .cascade, inverse: \PriceHistoryEntry.subscription)
    var priceHistory: [PriceHistoryEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \SharedPlan.subscription)
    var sharedPlan: SharedPlan?

    init(
        id: UUID = UUID(),
        name: String,
        iconAssetName: String? = nil,
        brandColorHex: String = "#8E8E93",
        amount: Decimal,
        currency: String = "TWD",
        billingCycle: BillingCycle = .monthly,
        firstPaymentDate: Date,
        status: SubscriptionStatus = .active,
        trialEndDate: Date? = nil,
        notes: String = "",
        reminderDaysBefore: Int = 1,
        isShared: Bool = false,
        isOrganizer: Bool = true,
        myShareOverride: Decimal? = nil,
        category: SubscriptionCategory? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.iconAssetName = iconAssetName
        self.brandColorHex = brandColorHex
        self.amount = amount
        self.currency = currency
        self.billingCycle = billingCycle
        self.firstPaymentDate = firstPaymentDate
        self.status = status
        self.trialEndDate = trialEndDate
        self.notes = notes
        self.reminderDaysBefore = reminderDaysBefore
        self.isShared = isShared
        self.isOrganizer = isOrganizer
        self.myShareOverride = myShareOverride
        self.category = category
        self.createdAt = createdAt
    }
}
