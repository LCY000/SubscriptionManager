import SwiftUI

struct FriendRowView: View {
    let friend: Friend

    private var outstanding: Decimal {
        friend.contributions.reduce(.zero) { sum, c in
            (c.currentStatus == .unpaid || c.currentStatus == .overdue) ? sum + c.amountPerMonth : sum
        }
    }

    private var overdueCount: Int {
        friend.contributions.filter { $0.currentStatus == .overdue }.count
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.accentColor.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Text(String(friend.name.prefix(1)).uppercased())
                        .font(.headline.bold())
                        .foregroundStyle(.tint)
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(friend.name)
                    .font(.headline)

                if friend.paymentInfo.isEmpty {
                    Text("未設定付款資訊")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                } else {
                    Text(friend.paymentInfo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if outstanding > 0 {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(outstanding.formatted(.currency(code: "TWD")))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(overdueCount > 0 ? Color.red : Color.orange)

                    Text("未收款")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}
