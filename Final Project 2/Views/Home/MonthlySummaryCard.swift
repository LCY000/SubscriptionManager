import SwiftUI

struct MonthlySummaryCard: View {
    let total: Decimal
    let currency: String
    let activeCount: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("本月預估支出")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(total.formatted(.currency(code: currency)))
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)

            Text("共 \(activeCount) 項啟用中訂閱")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            LinearGradient(
                colors: [Color.accentColor.opacity(0.18), Color.accentColor.opacity(0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 20))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("本月預估支出 \(total.formatted(.currency(code: currency)))，共 \(activeCount) 項啟用中訂閱")
    }
}

#Preview {
    MonthlySummaryCard(total: 1240, currency: "TWD", activeCount: 5)
        .padding()
}
