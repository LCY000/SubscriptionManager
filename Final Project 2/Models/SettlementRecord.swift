import Foundation
import SwiftData

@Model
final class SettlementRecord {
    var id: UUID = UUID()
    var periodStart: Date = Date()
    var amount: Decimal = Decimal.zero
    var outcome: SettlementOutcome = SettlementOutcome.unpaid
    var settledAt: Date = Date()
    var note: String = ""

    var contribution: Contribution?

    init(
        id: UUID = UUID(),
        periodStart: Date,
        amount: Decimal,
        outcome: SettlementOutcome,
        settledAt: Date = Date(),
        note: String = "",
        contribution: Contribution? = nil
    ) {
        self.id = id
        self.periodStart = periodStart
        self.amount = amount
        self.outcome = outcome
        self.settledAt = settledAt
        self.note = note
        self.contribution = contribution
    }
}
