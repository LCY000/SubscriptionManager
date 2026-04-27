import Foundation
import SwiftData

@Model
final class PaymentRecord {
    var id: UUID = UUID()
    var paidDate: Date = Date()
    var amount: Decimal = Decimal.zero        // 我的份額
    var planAmount: Decimal = Decimal.zero   // 方案全額（快照）
    var currency: String = "TWD"
    var note: String = ""

    var subscription: Subscription?

    init(
        id: UUID = UUID(),
        paidDate: Date = Date(),
        amount: Decimal,
        planAmount: Decimal = Decimal.zero,
        currency: String = "TWD",
        note: String = "",
        subscription: Subscription? = nil
    ) {
        self.id = id
        self.paidDate = paidDate
        self.amount = amount
        self.planAmount = planAmount
        self.currency = currency
        self.note = note
        self.subscription = subscription
    }
}
