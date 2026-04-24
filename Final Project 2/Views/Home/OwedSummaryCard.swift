import SwiftUI

struct OwedSummaryCard: View {
    let totalOwed: Decimal
    let overdueCount: Int
    let unpaidCount: Int
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: onTap ?? {}) {
            HStack(spacing: 16) {
                Image(systemName: overdueCount > 0 ? "exclamationmark.triangle.fill" : "person.2.fill")
                    .font(.title2)
                    .foregroundStyle(overdueCount > 0 ? Color.red : Color.orange)
                    .frame(width: 40)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("有人欠我")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)

                    Text(statusLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(totalOwed.formatted(.currency(code: "TWD")))
                    .font(.headline)
                    .foregroundStyle(overdueCount > 0 ? Color.red : Color.orange)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("有人欠我 \(totalOwed.formatted(.currency(code: "TWD")))，\(statusLabel)")
    }

    private var statusLabel: String {
        var parts: [String] = []
        if overdueCount > 0 { parts.append("逾期 \(overdueCount) 筆") }
        if unpaidCount > 0 { parts.append("未付 \(unpaidCount) 筆") }
        return parts.isEmpty ? "查看分帳" : parts.joined(separator: "・")
    }
}

#Preview {
    VStack(spacing: 16) {
        OwedSummaryCard(totalOwed: 1240, overdueCount: 1, unpaidCount: 2)
        OwedSummaryCard(totalOwed: 400, overdueCount: 0, unpaidCount: 2)
    }
    .padding()
}
