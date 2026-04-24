import SwiftUI

struct UpcomingPaymentsSection: View {
    let subscriptions: [Subscription]
    let calculator: BillingCycleCalculator

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("即將扣款")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(subscriptions) { subscription in
                    let daysUntil = calculator.daysUntilNextPayment(
                        firstPaymentDate: subscription.firstPaymentDate,
                        billingCycle: subscription.billingCycle
                    )
                    UpcomingPaymentRow(subscription: subscription, daysUntil: daysUntil)

                    if subscription.id != subscriptions.last?.id {
                        Divider()
                            .padding(.leading, 64)
                    }
                }
            }
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
}
