import SwiftUI

struct SubscriptionRowView: View {
    let subscription: Subscription
    private let calculator = BillingCycleCalculator()
    private let shareCalculator = SubscriptionShareCalculator()

    private var daysUntil: Int {
        calculator.daysUntilNextPayment(
            firstPaymentDate: subscription.firstPaymentDate,
            billingCycle: subscription.billingCycle
        )
    }

    private var myAmount: Decimal { shareCalculator.myAmount(for: subscription) }
    private var hasSharedSplit: Bool { subscription.isShared && myAmount != subscription.amount }

    var body: some View {
        HStack(spacing: 12) {
            BrandIconView(name: subscription.name, colorHex: subscription.brandColorHex, iconAssetName: subscription.iconAssetName)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(subscription.name)
                        .font(.headline)
                    if subscription.isShared {
                        Image(systemName: subscription.isOrganizer ? "person.2.fill" : "person.fill.checkmark")
                            .font(.caption2)
                            .foregroundStyle(subscription.isOrganizer ? Color.blue : Color.purple)
                            .accessibilityHidden(true)
                    }
                }
                Text(subscription.billingCycle.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(myAmount.formatted(.currency(code: subscription.currency)))
                    .font(.headline)

                if hasSharedSplit {
                    Text("方案 \(subscription.amount.formatted(.currency(code: subscription.currency)))")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

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
            "\(subscription.name)，\(subscription.billingCycle.displayName)，你付\(myAmount.formatted(.currency(code: subscription.currency)))，\(daysUntil == 0 ? "今天扣款" : "\(daysUntil) 天後扣款")"
        )
    }
}
