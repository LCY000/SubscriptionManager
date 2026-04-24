import Foundation

enum BillingCycle: Codable, Hashable {
    case weekly
    case monthly
    case quarterly
    case semiAnnual
    case yearly
    case customDays(Int)
}

enum SubscriptionStatus: String, Codable, Hashable, CaseIterable {
    case active
    case paused
    case cancelled
    case trial
}

enum ContributionStatus: String, Codable, Hashable, CaseIterable {
    case paid
    case prepaid
    case unpaid
    case overdue
}

enum SettlementOutcome: String, Codable, Hashable {
    case paidFromPrepay
    case paidByHand
    case unpaid
}

struct CustomShare: Codable, Hashable {
    var friendId: UUID
    var amount: Decimal
}

enum SplitMethod: Codable, Hashable {
    case equal
    case custom([CustomShare])
}
