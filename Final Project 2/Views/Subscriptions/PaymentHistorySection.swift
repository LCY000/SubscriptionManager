import SwiftUI

struct PaymentHistorySection: View {
    let records: [PaymentRecord]

    private var sortedRecords: [PaymentRecord] {
        records.sorted { $0.paidDate > $1.paidDate }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("付款紀錄")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(sortedRecords.prefix(10)) { record in
                    HStack {
                        Text(record.paidDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(record.amount.formatted(.currency(code: record.currency)))
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                    if record.id != sortedRecords.prefix(10).last?.id {
                        Divider()
                            .padding(.leading)
                    }
                }
            }
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
}
