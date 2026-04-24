import SwiftUI
import SwiftData

struct AddPrepaySheet: View {
    let contribution: Contribution
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var months: Int = 1

    private var subscriptionName: String {
        contribution.sharedPlan?.subscription?.name ?? "訂閱"
    }

    private var totalAmount: Decimal {
        contribution.amountPerMonth * Decimal(months)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper("預付 \(months) 個月", value: $months, in: 1...24)

                    LabeledContent("預付總金額") {
                        Text(totalAmount.formatted(.currency(code: "TWD")))
                            .foregroundStyle(.primary)
                    }

                    LabeledContent("每月金額") {
                        Text(contribution.amountPerMonth.formatted(.currency(code: "TWD")))
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(subscriptionName)
                } footer: {
                    Text("預付月份將自動逐月扣抵，抵完後進入未付狀態。")
                }
            }
            .navigationTitle("新增預付月份")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("確認", action: save)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func save() {
        ContributionSettlerService.addPrepay(contribution: contribution, months: months)
        dismiss()
    }
}
