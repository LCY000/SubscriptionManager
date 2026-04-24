import SwiftUI

struct UpcomingPaymentRow: View {
    let subscription: Subscription
    let daysUntil: Int

    var body: some View {
        HStack(spacing: 12) {
            BrandIconView(name: subscription.name, colorHex: subscription.brandColorHex, iconAssetName: subscription.iconAssetName, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.name)
                    .font(.subheadline.weight(.medium))
                Text(subscription.billingCycle.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(subscription.amount.formatted(.currency(code: subscription.currency)))
                    .font(.subheadline.weight(.medium))

                if daysUntil == 0 {
                    Text("今天")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.red)
                } else {
                    Text("\(daysUntil) 天後")
                        .font(.caption)
                        .foregroundStyle(daysUntil <= 3 ? Color.orange : Color.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(subscription.name)，\(subscription.amount.formatted(.currency(code: subscription.currency)))，\(daysUntil == 0 ? "今天扣款" : "\(daysUntil) 天後扣款")"
        )
    }
}
