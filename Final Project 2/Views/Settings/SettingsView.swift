import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("userNickname") private var userNickname = ""
    @AppStorage("defaultCurrency") private var defaultCurrency = "TWD"
    @AppStorage("defaultReminderDays") private var defaultReminderDays = 1
    @AppStorage("notificationHour") private var notificationHour = 9
    @AppStorage("appLockEnabled") private var appLockEnabled = false
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @AppStorage("primaryCurrency") private var primaryCurrency = "TWD"

    @State private var usdRate: String = ""
    @State private var jpyRate: String = ""
    @State private var eurRate: String = ""
    @State private var showingExportSheet = false
    @State private var exportCSV: String = ""

    @Query private var subscriptions: [Subscription]

    var body: some View {
        List {
            // MARK: 個人
            Section("個人") {
                HStack {
                    Text("我的暱稱")
                    Spacer()
                    TextField("用於分享訊息", text: $userNickname)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: 通知
            Section("通知") {
                Stepper(
                    "預設提前 \(defaultReminderDays) 天提醒",
                    value: $defaultReminderDays,
                    in: 0...30
                )
                Picker("提醒時間", selection: $notificationHour) {
                    ForEach([7, 8, 9, 10, 11, 12], id: \.self) { hour in
                        Text("\(hour):00").tag(hour)
                    }
                }
            }

            // MARK: 分類
            Section("分類") {
                NavigationLink("管理分類") {
                    CategoryManagementView()
                }
            }

            // MARK: 安全性（Face ID / Touch ID）
            Section {
                Toggle(isOn: $appLockEnabled) {
                    Label("App 鎖（Face ID / 密碼）", systemImage: "faceid")
                }
            } header: {
                Text("安全性")
            } footer: {
                Text("開啟後，每次從背景回到 App 需要驗證身份。需在裝置設定啟用 Face ID / Touch ID。")
            }

            // MARK: iCloud 同步
            Section {
                Toggle(isOn: $iCloudSyncEnabled) {
                    Label("iCloud 同步", systemImage: "icloud")
                }
            } header: {
                Text("同步")
            } footer: {
                Text("開啟後重新啟動 App 生效。需在 Xcode 專案中加入 iCloud + CloudKit capability，否則將自動回退到本地儲存。")
            }

            // MARK: 多幣別
            Section("主顯示幣別") {
                Picker("主幣別", selection: $primaryCurrency) {
                    ForEach(CurrencyConverter.supportedCurrencies, id: \.self) { code in
                        Text("\(CurrencyConverter.symbol(for: code)) \(code)").tag(code)
                    }
                }
                .pickerStyle(.menu)
            }

            if primaryCurrency != "TWD" {
                Section {
                    rateRow(label: "USD → TWD", key: "USD", binding: $usdRate, placeholder: "32")
                    rateRow(label: "JPY → TWD", key: "JPY", binding: $jpyRate, placeholder: "0.21")
                    rateRow(label: "EUR → TWD", key: "EUR", binding: $eurRate, placeholder: "35")
                } header: {
                    Text("兌換率（相對 TWD）")
                } footer: {
                    Text("1 單位外幣 = 幾元台幣。留空使用預設值。")
                }
            }

            // MARK: 匯出
            Section("資料") {
                Button {
                    exportCSV = ExportService.csvString(from: subscriptions)
                    showingExportSheet = true
                } label: {
                    Label("匯出 CSV", systemImage: "square.and.arrow.up")
                }
                .accessibilityLabel("匯出所有訂閱為 CSV 格式")
            }

            // MARK: 關於
            Section("關於") {
                LabeledContent("版本", value: "1.0.0")
                LabeledContent("Bundle ID", value: "work.Final-Project-2")
            }
        }
        .navigationTitle("設定")
        .onAppear(perform: loadRates)
        .sheet(isPresented: $showingExportSheet) {
            if let url = writeCSVTempFile(exportCSV) {
                ShareLink(
                    item: url,
                    preview: SharePreview("訂閱清單.csv", image: Image(systemName: "doc.text"))
                )
                .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Rate Row

    private func rateRow(label: String, key: String, binding: Binding<String>, placeholder: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField(placeholder, text: binding)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .onChange(of: binding.wrappedValue) { _, newValue in
                    if let rate = Decimal(string: newValue), rate > 0 {
                        CurrencyConverter.setRate(rate, from: key)
                    }
                }
        }
    }

    // MARK: - Helpers

    private func loadRates() {
        let usd = CurrencyConverter.rateToTWD(from: "USD")
        let jpy = CurrencyConverter.rateToTWD(from: "JPY")
        let eur = CurrencyConverter.rateToTWD(from: "EUR")
        usdRate = "\(usd)"
        jpyRate = "\(jpy)"
        eurRate = "\(eur)"
    }

    private func writeCSVTempFile(_ csv: String) -> URL? {
        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("訂閱清單_\(Date().timeIntervalSince1970).csv")
        try? csv.write(to: tmpURL, atomically: true, encoding: .utf8)
        return tmpURL
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(
        for: [Subscription.self, SubscriptionCategory.self, PaymentRecord.self,
              PriceHistoryEntry.self, Friend.self, SharedPlan.self,
              Contribution.self, SettlementRecord.self],
        inMemory: true
    )
}
