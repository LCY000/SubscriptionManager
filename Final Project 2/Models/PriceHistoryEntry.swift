import Foundation
import SwiftData

@Model
final class PriceHistoryEntry {
    var id: UUID = UUID()
    var oldAmount: Decimal = Decimal.zero
    var newAmount: Decimal = Decimal.zero
    var changedAt: Date = Date()
    var note: String = ""

    var subscription: Subscription?

    init(
        id: UUID = UUID(),
        oldAmount: Decimal,
        newAmount: Decimal,
        changedAt: Date = Date(),
        note: String = "",
        subscription: Subscription? = nil
    ) {
        self.id = id
        self.oldAmount = oldAmount
        self.newAmount = newAmount
        self.changedAt = changedAt
        self.note = note
        self.subscription = subscription
    }
}
