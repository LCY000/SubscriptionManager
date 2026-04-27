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
        // Priority: recipientName matched member → suggestedShare → full amount
        let initialShare: Decimal
        if let recipientName = payload.recipientName,
           let matched = payload.members?.first(where: { $0.name == recipientName }) {
            initialShare = matched.amountPerCycle
        } else if let suggested = payload.suggestedShare {
            initialShare = suggested
        } else {
            initialShare = payload.amount
        }
        _myShareString = State(initialValue: "\(initialShare)")
    }

    private var amountFooter: String {
        if payload.recipientName != nil {
            if let org = payload.organizerName, !org.isEmpty {
                return "由 \(org) 分配的金額，可自行調整"
            } else {
                return "由分享者分配的金額，可自行調整"
            }
        } else if payload.suggestedShare != nil {
            return "分享者提供的參考金額，可自行調整"
        } else {
            return "請填入你實際分擔的金額"
        }
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

                if let organizerName = payload.organizerName, !organizerName.isEmpty {
                    Section("主辦人") {
                        Label(organizerName, systemImage: "person.fill")
                    }
                }

                if let members = payload.members, !members.isEmpty {
                    Section("共享成員") {
                        ForEach(members, id: \.name) { member in
                            HStack {
                                if member.name == payload.recipientName {
                                    Image(systemName: "person.fill.checkmark")
                                        .foregroundStyle(.blue)
                                        .font(.caption)
                                }
                                Text(member.name)
                                    .fontWeight(member.name == payload.recipientName ? .semibold : .regular)
                                if member.isOrganizer {
                                    Text("主辦人")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(member.amountPerCycle.formatted(.currency(code: payload.currency)))
                                    .foregroundStyle(member.name == payload.recipientName ? .primary : .secondary)
                            }
                        }
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
                    Text(roleIsMember ? amountFooter : "整個方案會以你個人訂閱方式記錄全額")
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

        var membersJSON: String? = nil
        if roleIsMember,
           let members = payload.members, !members.isEmpty,
           let data = try? JSONEncoder().encode(members),
           let str = String(data: data, encoding: .utf8) {
            membersJSON = str
        }

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
            importedMembersJSON: membersJSON,
            category: category
        )
        modelContext.insert(sub)
        PaymentAutoGenerator.run(for: sub, in: modelContext)
        Task { await ReminderScheduler.schedule(for: sub) }
        onDismiss()
    }
}
