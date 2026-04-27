import SwiftUI
import SwiftData

struct PaymentHistorySection: View {
    let subscription: Subscription
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false
    @State private var editingRecord: PaymentRecord?

    private var sortedRecords: [PaymentRecord] {
        subscription.paymentRecords.sorted { $0.paidDate > $1.paidDate }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("付款紀錄")
                    .font(.headline)
                Spacer()
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(.blue)
                }
                .accessibilityLabel("新增付款紀錄")
            }
            .padding(.horizontal)

            if sortedRecords.isEmpty {
                Text("尚無付款紀錄")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 16))
                    .padding(.horizontal)
            } else {
                VStack(spacing: 0) {
                    ForEach(sortedRecords) { record in
                        HStack {
                            Text(record.paidDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            if !record.note.isEmpty {
                                Text(record.note)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Text(record.amount.formatted(.currency(code: record.currency)))
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                        .onTapGesture { editingRecord = record }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                modelContext.delete(record)
                            } label: {
                                Label("刪除", systemImage: "trash")
                            }
                        }

                        if record.id != sortedRecords.last?.id {
                            Divider().padding(.leading)
                        }
                    }
                }
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            PaymentRecordEditView(subscription: subscription)
        }
        .sheet(item: $editingRecord) { record in
            PaymentRecordEditView(subscription: subscription, record: record)
        }
    }
}
