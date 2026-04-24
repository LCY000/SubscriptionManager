// SubscriptionWidget.swift
//
// MARK: Xcode 設定步驟（必做）
// 1. File > New > Target > Widget Extension，命名 "SubscriptionWidget"，不要勾 Include Configuration App Intent
// 2. 主 App target 與 Widget target 都在 Signing & Capabilities 加入 App Groups：group.work.Final-Project-2
// 3. 將此檔案的 target membership 設為 SubscriptionWidget（不是主 App）
// 4. 在主 App 的 SubscriptionListView 或 ContentView 呼叫 WidgetCenter.shared.reloadAllTimelines() 讓 widget 刷新

import WidgetKit
import SwiftUI
import SwiftData

// Color(hex:) は ColorExtensions.swift で定義済み（主 App target）
// Widget Extension target に移行する際は ColorExtensions.swift を Widget target にも追加するか、
// 下記をコメント解除してください:
//
// private extension Color {
//     init(hex: String) {
//         let t = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
//         var v: UInt64 = 0
//         Scanner(string: t).scanHexInt64(&v)
//         self.init(red: Double((v >> 16) & 0xFF) / 255,
//                   green: Double((v >> 8) & 0xFF) / 255,
//                   blue: Double(v & 0xFF) / 255)
//     }
// }

// MARK: - Shared Data

private let appGroupID = "group.work.Final-Project-2"

struct WidgetSubscription: Codable {
    let name: String
    let amount: Double
    let currency: String
    let brandColorHex: String
    let daysUntilPayment: Int
}

struct WidgetData: Codable {
    let monthlyTotal: Double
    let primaryCurrency: String
    let upcoming: [WidgetSubscription]
    let updatedAt: Date
}

// MARK: - Data Loader（主 App 寫入，Widget 讀取）

struct WidgetDataStore {
    static func save(_ data: WidgetData) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: "widgetData")
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func load() -> WidgetData? {
        guard
            let defaults = UserDefaults(suiteName: appGroupID),
            let data = defaults.data(forKey: "widgetData"),
            let decoded = try? JSONDecoder().decode(WidgetData.self, from: data)
        else { return nil }
        return decoded
    }
}

// MARK: - Timeline Provider

struct SubscriptionEntry: TimelineEntry {
    let date: Date
    let widgetData: WidgetData?
}

struct SubscriptionWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SubscriptionEntry {
        SubscriptionEntry(date: Date(), widgetData: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SubscriptionEntry) -> Void) {
        completion(SubscriptionEntry(date: Date(), widgetData: WidgetDataStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SubscriptionEntry>) -> Void) {
        let data = WidgetDataStore.load()
        let entry = SubscriptionEntry(date: Date(), widgetData: data)
        // 每小時更新一次
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Small Widget View（本月總支出）

struct SmallWidgetView: View {
    let data: WidgetData?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("訂閱管家", systemImage: "creditcard.fill")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            if let d = data {
                Text(Decimal(d.monthlyTotal).formatted(.currency(code: d.primaryCurrency).precision(.fractionLength(0))))
                    .font(.title2.bold())
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("本月預估")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("--")
                    .font(.title2.bold())
                Text("本月預估")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget View（近 3 筆即將扣款）

struct MediumWidgetView: View {
    let data: WidgetData?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Label("即將扣款", systemImage: "calendar.badge.clock")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                if let d = data {
                    Text(Decimal(d.monthlyTotal).formatted(.currency(code: d.primaryCurrency).precision(.fractionLength(0))))
                        .font(.caption.weight(.semibold))
                }
            }
            .padding(.bottom, 8)

            if let upcoming = data?.upcoming, !upcoming.isEmpty {
                ForEach(Array(upcoming.prefix(3).enumerated()), id: \.offset) { _, sub in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: sub.brandColorHex))
                            .frame(width: 4, height: 28)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(sub.name)
                                .font(.caption.weight(.medium))
                                .lineLimit(1)
                            Text(sub.daysUntilPayment == 0 ? "今天" : "\(sub.daysUntilPayment) 天後")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(Decimal(sub.amount).formatted(.currency(code: sub.currency)))
                            .font(.caption.monospacedDigit())
                    }
                    .padding(.vertical, 3)
                }
            } else {
                Spacer()
                Text("近期無扣款")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Entry View

struct SubscriptionWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: SubscriptionEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(data: entry.widgetData)
        case .systemMedium:
            MediumWidgetView(data: entry.widgetData)
        default:
            SmallWidgetView(data: entry.widgetData)
        }
    }
}

// MARK: - Widget Configuration

struct SubscriptionWidget: Widget {
    let kind = "SubscriptionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubscriptionWidgetProvider()) { entry in
            SubscriptionWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("訂閱管家")
        .description("顯示本月訂閱支出與即將扣款項目")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    SubscriptionWidget()
} timeline: {
    SubscriptionEntry(date: Date(), widgetData: WidgetData(
        monthlyTotal: 1240,
        primaryCurrency: "TWD",
        upcoming: [
            WidgetSubscription(name: "Netflix", amount: 390, currency: "TWD", brandColorHex: "#E50914", daysUntilPayment: 2),
            WidgetSubscription(name: "Spotify", amount: 149, currency: "TWD", brandColorHex: "#1DB954", daysUntilPayment: 5),
        ],
        updatedAt: Date()
    ))
}
