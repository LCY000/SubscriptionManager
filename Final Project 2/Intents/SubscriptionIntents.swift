import AppIntents
import SwiftData
import Foundation

// MARK: - 本月花費

struct MonthlySpendIntent: AppIntent {
    static var title: LocalizedStringResource = "本月訂閱花費"
    static var description = IntentDescription("查詢本月訂閱預估總支出")

    func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
        let container = try ModelContainer(
            for: Subscription.self, SubscriptionCategory.self,
            PaymentRecord.self, PriceHistoryEntry.self,
            Friend.self, SharedPlan.self, Contribution.self, SettlementRecord.self
        )
        let context = ModelContext(container)
        let subscriptions = try context.fetch(FetchDescriptor<Subscription>())
        let currency = UserDefaults.standard.string(forKey: "primaryCurrency") ?? "TWD"

        let shareCalc = SubscriptionShareCalculator()
        let total = subscriptions
            .filter { $0.status == .active || $0.status == .trial }
            .reduce(Decimal.zero) { sum, sub in
                let monthly = shareCalc.myMonthlyShare(for: sub)
                let converted = CurrencyConverter.convert(monthly, from: sub.currency, to: currency)
                return sum + converted
            }

        let formatted = total.formatted(.currency(code: currency).precision(.fractionLength(0)))
        return .result(value: formatted, dialog: "你這個月訂閱預估支出為 \(formatted)")
    }
}

// MARK: - 下一筆扣款

struct NextPaymentIntent: AppIntent {
    static var title: LocalizedStringResource = "下一筆訂閱扣款"
    static var description = IntentDescription("查詢最近一筆即將扣款的訂閱")

    func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
        let container = try ModelContainer(
            for: Subscription.self, SubscriptionCategory.self,
            PaymentRecord.self, PriceHistoryEntry.self,
            Friend.self, SharedPlan.self, Contribution.self, SettlementRecord.self
        )
        let context = ModelContext(container)
        let subscriptions = try context.fetch(FetchDescriptor<Subscription>())

        let calc = BillingCycleCalculator()
        let active = subscriptions.filter { $0.status == .active || $0.status == .trial }
        guard let next = active.min(by: {
            calc.daysUntilNextPayment(firstPaymentDate: $0.firstPaymentDate, billingCycle: $0.billingCycle) <
            calc.daysUntilNextPayment(firstPaymentDate: $1.firstPaymentDate, billingCycle: $1.billingCycle)
        }) else {
            return .result(value: "無", dialog: "目前沒有啟用中的訂閱")
        }

        let shareCalc = SubscriptionShareCalculator()
        let days = calc.daysUntilNextPayment(firstPaymentDate: next.firstPaymentDate, billingCycle: next.billingCycle)
        let myAmount = shareCalc.myAmount(for: next)
        let amount = myAmount.formatted(.currency(code: next.currency))
        let daysText = days == 0 ? "今天" : "\(days) 天後"
        let result = "\(next.name)，你付 \(amount)，\(daysText)"
        return .result(value: result, dialog: "下一筆訂閱扣款是 \(result)")
    }
}

// MARK: - Shortcuts Provider

struct SubscriptionShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: MonthlySpendIntent(),
            phrases: [
                "查詢\(.applicationName)本月花費",
                "\(.applicationName)這個月訂閱花多少",
                "\(.applicationName)我這個月訂閱花了多少",
            ],
            shortTitle: "本月訂閱花費",
            systemImageName: "creditcard"
        )
        AppShortcut(
            intent: NextPaymentIntent(),
            phrases: [
                "查詢\(.applicationName)下一筆扣款",
                "\(.applicationName)下一筆訂閱是什麼",
                "\(.applicationName)下一個訂閱扣款",
            ],
            shortTitle: "下一筆扣款",
            systemImageName: "calendar.badge.clock"
        )
    }
}
