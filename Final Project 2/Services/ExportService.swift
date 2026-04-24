import Foundation

struct ExportService {
    private static let iso = ISO8601DateFormatter()
    private static let calc = BillingCycleCalculator()

    static func csvString(from subscriptions: [Subscription]) -> String {
        let header = "名稱,金額,幣別,月均金額,付款週期,首次扣款日,下次扣款日,狀態,分類,備註,建立日期"
        let rows = subscriptions
            .sorted { $0.name < $1.name }
            .map { csvRow($0) }
        return ([header] + rows).joined(separator: "\n")
    }

    private static func csvRow(_ sub: Subscription) -> String {
        let nextDate = calc.nextPaymentDate(
            firstPaymentDate: sub.firstPaymentDate,
            billingCycle: sub.billingCycle
        )
        let monthly = calc.monthlyEquivalent(amount: sub.amount, cycle: sub.billingCycle)
        let fields: [String] = [
            sub.name.csvEscaped,
            "\(sub.amount)",
            sub.currency,
            NSDecimalNumber(decimal: monthly).stringValue,
            sub.billingCycle.displayName,
            iso.string(from: sub.firstPaymentDate),
            iso.string(from: nextDate),
            sub.status.displayName,
            (sub.category?.name ?? "").csvEscaped,
            sub.notes.csvEscaped,
            iso.string(from: sub.createdAt),
        ]
        return fields.joined(separator: ",")
    }
}

private extension String {
    var csvEscaped: String {
        if contains(",") || contains("\"") || contains("\n") {
            return "\"\(replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return self
    }
}
