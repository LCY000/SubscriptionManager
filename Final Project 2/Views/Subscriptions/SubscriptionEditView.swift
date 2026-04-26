import SwiftUI
import SwiftData

struct SubscriptionEditView: View {
    var subscription: Subscription?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \SubscriptionCategory.sortOrder)
    private var categories: [SubscriptionCategory]

    @State private var name: String = ""
    @State private var amountString: String = ""
    @State private var currency: String = "TWD"
    @State private var cycleType: BillingCyclePickerType = .monthly
    @State private var customDays: Int = 30
    @State private var firstPaymentDate: Date = Date()
    @State private var status: SubscriptionStatus = .active
    @State private var trialEndDate: Date = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
    @State private var reminderDaysBefore: Int = 1
    @State private var notes: String = ""
    @State private var shareMode: ShareMode = .solo
    @State private var myShareString: String = ""
    @State private var brandColorHex: String = "#007AFF"
    @State private var brandColor: Color = Color(hex: "#007AFF")
    @State private var selectedCategory: SubscriptionCategory?
    @State private var showingPresetPicker = false
    @State private var presetApplied = false
    @State private var iconAssetName: String? = nil

    private var isValid: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        return (Decimal(string: amountString) ?? .zero) > .zero
    }

    private var billingCycle: BillingCycle {
        switch cycleType {
        case .weekly:     .weekly
        case .monthly:    .monthly
        case .quarterly:  .quarterly
        case .semiAnnual: .semiAnnual
        case .yearly:     .yearly
        case .custom:     .customDays(max(1, customDays))
        }
    }

    init(subscription: Subscription? = nil) {
        self.subscription = subscription
        guard let sub = subscription else { return }
        _name = State(initialValue: sub.name)
        _amountString = State(initialValue: "\(sub.amount)")
        _currency = State(initialValue: sub.currency)
        _firstPaymentDate = State(initialValue: sub.firstPaymentDate)
        _status = State(initialValue: sub.status)
        _trialEndDate = State(initialValue: sub.trialEndDate ?? (Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()))
        _reminderDaysBefore = State(initialValue: sub.reminderDaysBefore)
        _notes = State(initialValue: sub.notes)
        let mode: ShareMode
        if !sub.isShared { mode = .solo }
        else if sub.isOrganizer { mode = .organizer }
        else { mode = .member }
        _shareMode = State(initialValue: mode)
        if let override = sub.myShareOverride {
            _myShareString = State(initialValue: "\(override)")
        }
        _brandColorHex = State(initialValue: sub.brandColorHex)
        _brandColor = State(initialValue: Color(hex: sub.brandColorHex))
        _selectedCategory = State(initialValue: sub.category)
        _iconAssetName = State(initialValue: sub.iconAssetName)
        switch sub.billingCycle {
        case .weekly:           _cycleType = State(initialValue: .weekly)
        case .monthly:          _cycleType = State(initialValue: .monthly)
        case .quarterly:        _cycleType = State(initialValue: .quarterly)
        case .semiAnnual:       _cycleType = State(initialValue: .semiAnnual)
        case .yearly:           _cycleType = State(initialValue: .yearly)
        case .customDays(let d):
            _cycleType = State(initialValue: .custom)
            _customDays = State(initialValue: d)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // 服務庫快選
                Section {
                    Button {
                        showingPresetPicker = true
                    } label: {
                        Label("從服務庫選擇", systemImage: "sparkles")
                            .foregroundStyle(.blue)
                    }
                }

                Section {
                    TextField("名稱（如：Netflix）", text: $name)
                        .autocorrectionDisabled()

                    HStack {
                        TextField("金額", text: $amountString)
                            .keyboardType(.decimalPad)
                        Text(currency)
                            .foregroundStyle(.secondary)
                    }

                    ColorPicker("品牌顏色", selection: $brandColor)
                        .onChange(of: brandColor) { _, newColor in
                            brandColorHex = newColor.toHex() ?? brandColorHex
                        }

                    if !categories.isEmpty {
                        Picker("分類", selection: $selectedCategory) {
                            Text("無分類").tag(nil as SubscriptionCategory?)
                            ForEach(categories) { cat in
                                Label(cat.name, systemImage: cat.iconName)
                                    .tag(cat as SubscriptionCategory?)
                            }
                        }
                    }
                } header: {
                    Text("基本資訊")
                } footer: {
                    if presetApplied {
                        Text("金額已自動填入，可依實際費用調整")
                    }
                }

                Section("付款週期") {
                    Picker("週期", selection: $cycleType) {
                        ForEach(BillingCyclePickerType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    if cycleType == .custom {
                        Stepper("每 \(customDays) 天", value: $customDays, in: 1...365)
                    }

                    DatePicker("首次扣款日", selection: $firstPaymentDate, displayedComponents: .date)
                }

                Section("狀態") {
                    Picker("狀態", selection: $status) {
                        ForEach(SubscriptionStatus.allCases, id: \.self) { s in
                            Text(s.displayName).tag(s)
                        }
                    }

                    if status == .trial {
                        DatePicker("試用到期日", selection: $trialEndDate, displayedComponents: .date)
                    }

                    Stepper(
                        "到期前 \(reminderDaysBefore) 天提醒",
                        value: $reminderDaysBefore,
                        in: 0...30
                    )
                }

                Section {
                    Picker("分帳模式", selection: $shareMode) {
                        ForEach(ShareMode.allCases, id: \.self) { m in
                            Text(m.displayName).tag(m)
                        }
                    }

                    if shareMode == .member {
                        HStack {
                            TextField("我每次付", text: $myShareString)
                                .keyboardType(.decimalPad)
                            Text(currency)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("分帳")
                } footer: {
                    Text(shareModeFooter)
                        .font(.caption)
                }

                Section("其他") {
                    TextField("備註", text: $notes, axis: .vertical)
                        .lineLimit(3...)
                }
            }
            .navigationTitle(subscription == nil ? "新增訂閱" : "編輯訂閱")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("儲存", action: save)
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingPresetPicker) {
                ServicePresetPickerView { preset in
                    applyPreset(preset)
                }
            }
        }
    }

    private func applyPreset(_ preset: ServicePreset) {
        name = preset.name
        amountString = "\(preset.defaultAmount)"
        iconAssetName = preset.iconAssetName
        presetApplied = true
        currency = preset.currency
        brandColorHex = preset.brandColorHex
        brandColor = Color(hex: preset.brandColorHex)
        switch preset.defaultCycle {
        case .weekly:           cycleType = .weekly
        case .monthly:          cycleType = .monthly
        case .quarterly:        cycleType = .quarterly
        case .semiAnnual:       cycleType = .semiAnnual
        case .yearly:           cycleType = .yearly
        case .customDays(let d): cycleType = .custom; customDays = d
        }
        selectedCategory = categories.first { $0.name == preset.categoryName }
    }

    private var shareModeFooter: String {
        switch shareMode {
        case .solo:      "只記錄你個人的訂閱"
        case .organizer: "你是主辦人，可在詳情頁設定共用人數與向朋友收款"
        case .member:    "由朋友主辦，你只記錄自己每次扣款付的份額"
        }
    }

    private func save() {
        let amount = Decimal(string: amountString) ?? .zero
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let isShared = shareMode != .solo
        let isOrganizer = shareMode != .member
        let myShareOverride: Decimal? = shareMode == .member ? Decimal(string: myShareString) : nil
        let savedSub: Subscription

        if let sub = subscription {
            // 金額有變動時記錄價格歷史
            if sub.amount != amount {
                let entry = PriceHistoryEntry(
                    oldAmount: sub.amount,
                    newAmount: amount,
                    subscription: sub
                )
                modelContext.insert(entry)
            }
            sub.name = trimmedName
            sub.amount = amount
            sub.currency = currency
            sub.billingCycle = billingCycle
            sub.firstPaymentDate = firstPaymentDate
            sub.status = status
            sub.trialEndDate = status == .trial ? trialEndDate : nil
            sub.reminderDaysBefore = reminderDaysBefore
            sub.notes = notes
            sub.isShared = isShared
            sub.isOrganizer = isOrganizer
            sub.myShareOverride = myShareOverride
            sub.brandColorHex = brandColorHex
            sub.category = selectedCategory
            if let url = iconAssetName { sub.iconAssetName = url }
            // 切到「朋友主辦」時清掉舊的 SharedPlan
            if shareMode == .member, let oldPlan = sub.sharedPlan {
                modelContext.delete(oldPlan)
            }
            savedSub = sub
        } else {
            let newSub = Subscription(
                name: trimmedName,
                iconAssetName: iconAssetName,
                brandColorHex: brandColorHex,
                amount: amount,
                currency: currency,
                billingCycle: billingCycle,
                firstPaymentDate: firstPaymentDate,
                status: status,
                trialEndDate: status == .trial ? trialEndDate : nil,
                notes: notes,
                reminderDaysBefore: reminderDaysBefore,
                isShared: isShared,
                isOrganizer: isOrganizer,
                myShareOverride: myShareOverride,
                category: selectedCategory
            )
            modelContext.insert(newSub)
            savedSub = newSub
        }

        Task { await ReminderScheduler.schedule(for: savedSub) }
        dismiss()
    }
}

enum ShareMode: String, CaseIterable, Hashable {
    case solo
    case organizer
    case member

    var displayName: String {
        switch self {
        case .solo:      "一般"
        case .organizer: "我主辦分帳"
        case .member:    "朋友主辦我分擔"
        }
    }
}

// MARK: - Helpers

private enum BillingCyclePickerType: String, CaseIterable {
    case weekly, monthly, quarterly, semiAnnual, yearly, custom

    var displayName: String {
        switch self {
        case .weekly:     "每週"
        case .monthly:    "每月"
        case .quarterly:  "每季"
        case .semiAnnual: "每半年"
        case .yearly:     "每年"
        case .custom:     "自訂天數"
        }
    }
}

private extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else { return nil }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

#Preview {
    SubscriptionEditView()
        .modelContainer(
            for: [Subscription.self, SubscriptionCategory.self, PaymentRecord.self,
                  PriceHistoryEntry.self, Friend.self, SharedPlan.self,
                  Contribution.self, SettlementRecord.self],
            inMemory: true
        )
}
