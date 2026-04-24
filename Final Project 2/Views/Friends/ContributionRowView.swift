import SwiftUI
import SwiftData

struct ContributionRowView: View {
    let contribution: Contribution
    var onRemind: (() -> Void)?
    var onPaid: (() -> Void)?
    var onAddPrepay: (() -> Void)?

    private var subscriptionName: String {
        contribution.sharedPlan?.subscription?.name ?? "未知訂閱"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(subscriptionName)
                    .font(.headline)

                Spacer()

                Label(contribution.currentStatus.displayName, systemImage: contribution.currentStatus.iconName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(contribution.currentStatus.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(contribution.currentStatus.accentColor.opacity(0.12))
                    .clipShape(.capsule)
            }

            HStack {
                Text("每月 \(contribution.amountPerMonth.formatted(.currency(code: "TWD")))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if contribution.prepaidMonthsRemaining > 0 {
                    Text("・預付剩 \(contribution.prepaidMonthsRemaining) 個月")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }

            if contribution.currentStatus == .unpaid || contribution.currentStatus == .overdue {
                HStack(spacing: 8) {
                    Button("記錄已付", systemImage: "checkmark.circle") { onPaid?() }
                        .font(.caption.weight(.medium))
                        .tint(.green)

                    Button("新增預付", systemImage: "plus.circle") { onAddPrepay?() }
                        .font(.caption.weight(.medium))
                        .tint(.blue)

                    Spacer()

                    Button("催款", systemImage: "bell") { onRemind?() }
                        .font(.caption.weight(.medium))
                        .tint(.orange)
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            } else if contribution.currentStatus == .prepaid {
                Button("新增預付月份", systemImage: "plus.circle") { onAddPrepay?() }
                    .font(.caption.weight(.medium))
                    .tint(.blue)
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
            }
        }
        .padding(.vertical, 4)
    }
}
