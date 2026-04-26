import Foundation
import WidgetKit

// MARK: - 與 SubscriptionWidget.swift 共用的資料結構（鏡像）
// 兩邊透過 App Group UserDefaults 共享，key = "widgetData"

struct WidgetSubscriptionData: Codable {
    let name: String
    let amount: Double
    let currency: String
    let brandColorHex: String
    let daysUntilPayment: Int
}

struct WidgetSummaryData: Codable {
    let monthlyTotal: Double
    let primaryCurrency: String
    let upcoming: [WidgetSubscriptionData]
    let updatedAt: Date
}

// MARK: - Refresher

struct WidgetRefresher {
    private static let appGroupID = "group.work.Final-Project-2"
    private static let calc = BillingCycleCalculator()
    private static let shareCalc = SubscriptionShareCalculator()

    static func refresh(subscriptions: [Subscription]) {
        let primaryCurrency = UserDefaults.standard.string(forKey: "primaryCurrency") ?? "TWD"
        let active = subscriptions.filter { $0.status == .active || $0.status == .trial }

        let monthlyTotal = active.reduce(Decimal.zero) { sum, sub in
            let monthly = shareCalc.myMonthlyShare(for: sub)
            return sum + CurrencyConverter.convert(monthly, from: sub.currency, to: primaryCurrency)
        }

        let upcoming = active
            .sorted {
                calc.daysUntilNextPayment(firstPaymentDate: $0.firstPaymentDate, billingCycle: $0.billingCycle) <
                calc.daysUntilNextPayment(firstPaymentDate: $1.firstPaymentDate, billingCycle: $1.billingCycle)
            }
            .prefix(3)
            .map { sub in
                WidgetSubscriptionData(
                    name: sub.name,
                    amount: NSDecimalNumber(decimal: shareCalc.myAmount(for: sub)).doubleValue,
                    currency: sub.currency,
                    brandColorHex: sub.brandColorHex,
                    daysUntilPayment: calc.daysUntilNextPayment(
                        firstPaymentDate: sub.firstPaymentDate,
                        billingCycle: sub.billingCycle
                    )
                )
            }

        let data = WidgetSummaryData(
            monthlyTotal: NSDecimalNumber(decimal: monthlyTotal).doubleValue,
            primaryCurrency: primaryCurrency,
            upcoming: Array(upcoming),
            updatedAt: Date()
        )

        guard
            let defaults = UserDefaults(suiteName: appGroupID),
            let encoded = try? JSONEncoder().encode(data)
        else { return }

        defaults.set(encoded, forKey: "widgetData")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
