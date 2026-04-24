import SwiftUI
import SwiftData

struct HomeView: View {
    var selectTab: (AppTab) -> Void = { _ in }

    @Query private var subscriptions: [Subscription]
    @Query private var friends: [Friend]
    @AppStorage("primaryCurrency") private var primaryCurrency = "TWD"
    private let calculator = BillingCycleCalculator()

    private var activeSubscriptions: [Subscription] {
        subscriptions.filter { $0.status == .active || $0.status == .trial }
    }

    private var monthlyTotal: Decimal {
        activeSubscriptions.reduce(.zero) { sum, sub in
            let monthly = calculator.monthlyEquivalent(amount: sub.amount, cycle: sub.billingCycle)
            return sum + CurrencyConverter.convert(monthly, from: sub.currency, to: primaryCurrency)
        }
    }

    private var totalOwed: Decimal {
        friends.reduce(.zero) { sum, f in
            sum + ContributionSettlerService.totalOutstanding(for: f.contributions)
        }
    }

    private var overdueCount: Int {
        friends.flatMap(\.contributions).filter { $0.currentStatus == .overdue }.count
    }

    private var unpaidCount: Int {
        friends.flatMap(\.contributions).filter { $0.currentStatus == .unpaid }.count
    }

    private var upcomingSubscriptions: [Subscription] {
        activeSubscriptions
            .filter {
                calculator.daysUntilNextPayment(
                    firstPaymentDate: $0.firstPaymentDate,
                    billingCycle: $0.billingCycle
                ) <= 7
            }
            .sorted {
                calculator.daysUntilNextPayment(firstPaymentDate: $0.firstPaymentDate, billingCycle: $0.billingCycle)
                < calculator.daysUntilNextPayment(firstPaymentDate: $1.firstPaymentDate, billingCycle: $1.billingCycle)
            }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if subscriptions.isEmpty {
                    ContentUnavailableView {
                        Label("尚無訂閱", systemImage: "creditcard")
                    } description: {
                        Text("切換到「訂閱」頁面新增第一筆訂閱")
                    }
                    .padding(.top, 60)
                } else {
                    MonthlySummaryCard(
                        total: monthlyTotal,
                        currency: primaryCurrency,
                        activeCount: activeSubscriptions.count
                    )
                    .padding(.horizontal)

                    if totalOwed > 0 {
                        OwedSummaryCard(
                            totalOwed: totalOwed,
                            overdueCount: overdueCount,
                            unpaidCount: unpaidCount,
                            onTap: { selectTab(.friends) }
                        )
                        .padding(.horizontal)
                    }

                    if !upcomingSubscriptions.isEmpty {
                        UpcomingPaymentsSection(
                            subscriptions: upcomingSubscriptions,
                            calculator: calculator
                        )
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("訂閱管家")
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(
        for: [Subscription.self, SubscriptionCategory.self, PaymentRecord.self,
              PriceHistoryEntry.self, Friend.self, SharedPlan.self,
              Contribution.self, SettlementRecord.self],
        inMemory: true
    )
}
