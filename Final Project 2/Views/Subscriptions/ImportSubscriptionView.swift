import SwiftUI
import SwiftData

@Observable
final class ImportRouter {
    var pendingPayload: SharedSubscriptionPayload?
    var failureMessage: String?

    func handle(url: URL) {
        do {
            pendingPayload = try SubscriptionShareDecoder.decode(url)
        } catch SubscriptionShareError.unsupportedVersion {
            failureMessage = "此分享連結來自更新版本的訂閱管家，請更新 App"
        } catch {
            failureMessage = "無法讀取分享內容"
        }
    }

    func clear() {
        pendingPayload = nil
        failureMessage = nil
    }
}

struct ImportSubscriptionView: View {
    let payload: SharedSubscriptionPayload
    var onDismiss: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [SubscriptionCategory]
    @State private var myShareString: String = ""
    @State private var roleIsMember: Bool = true

    init(payload: SharedSubscriptionPayload, onDismiss: @escaping () -> Void) {
        self.payload = payload
        self.onDismiss = onDismiss
        let suggestion = payload.suggestedShare ?? payload.amount
        _myShareString = State(initialValue: "\(suggestion)")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    BrandIconView(name: payload.name, colorHex: payload.brandColorHex, iconAssetName: payload.iconAssetName, size: 56)
                        .frame(maxWidth: .infinity)
                    Text(payload.name)
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                } header: {
                    Text("方案資訊")
                }

                Section("方案內容") {
                    LabeledContent("方案金額",
                                   value: payload.amount.formatted(.currency(code: payload.currency)))
                    LabeledContent("付款週期", value: payload.billingCycle.displayName)
                    LabeledContent("首次扣款",
                                   value: payload.firstPaymentDate.formatted(date: .abbreviated, time: .omitted))
                    if let cat = payload.categoryName, !cat.isEmpty {
                        LabeledContent("分類", value: cat)
                    }
                }

                Section {
                    Toggle("由朋友主辦，我只記錄我的份額", isOn: $roleIsMember)
                    if roleIsMember {
                        HStack {
                            TextField("我每次付", text: $myShareString)
                                .keyboardType(.decimalPad)
                            Text(payload.currency)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("我的角色")
                } footer: {
                    Text(roleIsMember
                         ? "建議金額為對方分享時的設定，可調整"
                         : "整個方案會以你個人訂閱方式記錄全額")
                        .font(.caption)
                }
            }
            .navigationTitle("匯入訂閱方案")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消", action: onDismiss)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("加入", action: importNow)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func importNow() {
        let myShare: Decimal? = roleIsMember
            ? (Decimal(string: myShareString) ?? payload.suggestedShare)
            : nil

        let category = categories.first { $0.name == payload.categoryName }

        let sub = Subscription(
            name: payload.name,
            iconAssetName: payload.iconAssetName,
            brandColorHex: payload.brandColorHex,
            amount: payload.amount,
            currency: payload.currency,
            billingCycle: payload.billingCycle,
            firstPaymentDate: payload.firstPaymentDate,
            notes: payload.notes,
            isShared: roleIsMember,
            isOrganizer: !roleIsMember,
            myShareOverride: myShare,
            category: category
        )
        modelContext.insert(sub)
        Task { await ReminderScheduler.schedule(for: sub) }
        onDismiss()
    }
}
