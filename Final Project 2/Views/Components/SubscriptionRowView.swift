import SwiftUI

struct SubscriptionRowView: View {
    let subscription: Subscription
    private let calculator = BillingCycleCalculator()

    private var daysUntil: Int {
        calculator.daysUntilNextPayment(
            firstPaymentDate: subscription.firstPaymentDate,
            billingCycle: subscription.billingCycle
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            BrandIconView(name: subscription.name, colorHex: subscription.brandColorHex, iconAssetName: subscription.iconAssetName)

            VStack(alignment: .leading, spacing: 3) {
                Text(subscription.name)
                    .font(.headline)
                Text(subscription.billingCycle.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(subscription.amount.formatted(.currency(code: subscription.currency)))
                    .font(.headline)

                Group {
                    if daysUntil == 0 {
                        Text("今天扣款")
                            .foregroundStyle(.red)
                    } else if daysUntil <= 3 {
                        Text("\(daysUntil) 天後")
                            .foregroundStyle(.orange)
                    } else {
                        Text("\(daysUntil) 天後")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(subscription.name)，\(subscription.billingCycle.displayName)，\(subscription.amount.formatted(.currency(code: subscription.currency)))，\(daysUntil == 0 ? "今天扣款" : "\(daysUntil) 天後扣款")"
        )
    }
}
