import Foundation
import SwiftData

@Model
final class Contribution {
    var id: UUID = UUID()
    var amountPerMonth: Decimal = Decimal.zero
    var prepaidMonthsRemaining: Int = 0
    var lastSettledMonth: Date?
    var currentStatus: ContributionStatus = ContributionStatus.unpaid
    var createdAt: Date = Date()

    var friend: Friend?
    var sharedPlan: SharedPlan?

    @Relationship(deleteRule: .cascade, inverse: \SettlementRecord.contribution)
    var history: [SettlementRecord] = []

    init(
        id: UUID = UUID(),
        amountPerMonth: Decimal,
        prepaidMonthsRemaining: Int = 0,
        lastSettledMonth: Date? = nil,
        currentStatus: ContributionStatus = .unpaid,
        friend: Friend? = nil,
        sharedPlan: SharedPlan? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.amountPerMonth = amountPerMonth
        self.prepaidMonthsRemaining = prepaidMonthsRemaining
        self.lastSettledMonth = lastSettledMonth
        self.currentStatus = currentStatus
        self.friend = friend
        self.sharedPlan = sharedPlan
        self.createdAt = createdAt
    }
}
