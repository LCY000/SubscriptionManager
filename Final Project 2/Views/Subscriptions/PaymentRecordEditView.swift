import SwiftUI
import SwiftData

struct PaymentRecordEditView: View {
    let subscription: Subscription
    var record: PaymentRecord?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var paidDate: Date
    @State private var amountString: String
    @State private var note: String

    init(subscription: Subscription, record: PaymentRecord? = nil) {
        self.subscription = subscription
        self.record = record
        let shareCalc = SubscriptionShareCalculator()
        _paidDate = State(initialValue: record?.paidDate ?? Date())
        _amountString = State(initialValue: record.map { "\($0.amount)" } ?? "\(shareCalc.myAmount(for: subscription))")
        _note = State(initialValue: record?.note ?? "")
    }

    private var isValid: Bool {
        (Decimal(string: amountString) ?? .zero) > .zero
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("付款資訊") {
                    DatePicker("付款日期", selection: $paidDate, displayedComponents: .date)
                    HStack {
                        Text("金額")
                        Spacer()
                        TextField("0", text: $amountString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                        Text(subscription.currency)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("備註") {
                    TextField("選填", text: $note, axis: .vertical)
                        .lineLimit(3, reservesSpace: false)
                }
            }
            .navigationTitle(record == nil ? "新增付款紀錄" : "編輯付款紀錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("儲存", action: save)
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        let amount = Decimal(string: amountString) ?? .zero
        if let existing = record {
            existing.paidDate = paidDate
            existing.amount = amount
            existing.note = note
        } else {
            let newRecord = PaymentRecord(
                paidDate: paidDate,
                amount: amount,
                planAmount: subscription.amount,
                currency: subscription.currency,
                note: note,
                subscription: subscription
            )
            modelContext.insert(newRecord)
        }
        dismiss()
    }
}
