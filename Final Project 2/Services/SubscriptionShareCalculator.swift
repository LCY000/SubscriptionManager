import Foundation

struct SubscriptionShareCalculator {
    let billing: BillingCycleCalculator

    init(billing: BillingCycleCalculator = BillingCycleCalculator()) {
        self.billing = billing
    }

    func myAmount(for sub: Subscription) -> Decimal {
        if let override = sub.myShareOverride {
            return max(override, .zero)
        }
        if !sub.isShared {
            return sub.amount
        }
        if sub.isOrganizer, let plan = sub.sharedPlan {
            let othersTotal = plan.contributions.reduce(Decimal.zero) { $0 + $1.amountPerMonth }
            return max(sub.amount - othersTotal, .zero)
        }
        return sub.amount
    }

    func myMonthlyShare(for sub: Subscription) -> Decimal {
        billing.monthlyEquivalent(amount: myAmount(for: sub), cycle: sub.billingCycle)
    }

    func myYearlyShare(for sub: Subscription) -> Decimal {
        myMonthlyShare(for: sub) * Decimal(12)
    }
}
