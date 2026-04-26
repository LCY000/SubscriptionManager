import SwiftUI
import Charts
import SwiftData

enum StatisticsViewMode: String, CaseIterable, Identifiable {
    case myShare
    case planTotal
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .myShare:   "我的支出"
        case .planTotal: "方案總額"
        }
    }
}

struct StatisticsView: View {
    @Query private var allSubscriptions: [Subscription]
    @AppStorage("primaryCurrency") private var primaryCurrency = "TWD"
    @State private var viewMode: StatisticsViewMode = .myShare

    private let calculator = BillingCycleCalculator()
    private let shareCalculator = SubscriptionShareCalculator()

    private var activeSubscriptions: [Subscription] {
        allSubscriptions.filter { $0.status == .active || $0.status == .trial }
    }

    private func monthlyInPrimary(_ sub: Subscription) -> Decimal {
        let monthly: Decimal = viewMode == .myShare
            ? shareCalculator.myMonthlyShare(for: sub)
            : calculator.monthlyEquivalent(amount: sub.amount, cycle: sub.billingCycle)
        return CurrencyConverter.convert(monthly, from: sub.currency, to: primaryCurrency)
    }

    /// 用於圖表（按發生扣款日期累加），回傳該訂閱在那個扣款日的「換算後金額」
    private func amountForChart(_ sub: Subscription) -> Decimal {
        let raw: Decimal = viewMode == .myShare ? shareCalculator.myAmount(for: sub) : sub.amount
        return CurrencyConverter.convert(raw, from: sub.currency, to: primaryCurrency)
    }

    private var monthlyTotal: Decimal {
        activeSubscriptions.reduce(.zero) { $0 + monthlyInPrimary($1) }
    }

    private var yearlyTotal: Decimal { monthlyTotal * 12 }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                viewModePicker
                summaryRow
                if !allSubscriptions.isEmpty {
                    monthlyChartCard
                    yearlyTrendCard
                    if !categoryData.isEmpty {
                        categoryChartCard
                    }
                    if !activeSubscriptions.isEmpty {
                        topSubscriptionsCard
                    }
                } else {
                    emptyState
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("統計")
    }

    private var viewModePicker: some View {
        Picker("檢視", selection: $viewMode) {
            ForEach(StatisticsViewMode.allCases) { mode in
                Text(mode.displayName).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    // MARK: - Summary

    private var summaryRow: some View {
        HStack(spacing: 10) {
            StatSummaryTile(
                title: "本月預估",
                value: monthlyTotal.formatted(.currency(code: primaryCurrency).precision(.fractionLength(0))),
                icon: "calendar",
                color: .blue
            )
            StatSummaryTile(
                title: "年度預估",
                value: yearlyTotal.formatted(.currency(code: primaryCurrency).precision(.fractionLength(0))),
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            )
            StatSummaryTile(
                title: "訂閱數",
                value: "\(activeSubscriptions.count)",
                icon: "creditcard.fill",
                color: .purple
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Monthly Chart

    private struct MonthlySpending: Identifiable {
        let id = UUID()
        let label: String
        let amount: Decimal
    }

    private var monthlyChartData: [MonthlySpending] {
        let calendar = Calendar.current
        let now = Date()

        var totals: [Date: Decimal] = [:]

        for sub in allSubscriptions where sub.status != .cancelled {
            guard
                let sixMonthsAgo = calendar.date(byAdding: .month, value: -5, to: now),
                let monthStart = calendar.date(
                    from: calendar.dateComponents([.year, .month], from: sixMonthsAgo)
                )
            else { continue }

            let dates = calculator.paymentDates(
                firstPaymentDate: sub.firstPaymentDate,
                billingCycle: sub.billingCycle,
                through: now
            )

            for date in dates where date >= monthStart {
                guard let key = calendar.date(
                    from: calendar.dateComponents([.year, .month], from: date)
                ) else { continue }
                totals[key, default: .zero] += amountForChart(sub)
            }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "M月"

        return (0..<6).reversed().compactMap { offset -> MonthlySpending? in
            guard
                let monthDate = calendar.date(byAdding: .month, value: -offset, to: now),
                let key = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))
            else { return nil }
            return MonthlySpending(label: formatter.string(from: monthDate), amount: totals[key] ?? .zero)
        }
    }

    private var monthlyChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("月度支出（近 6 個月）")
                .font(.headline)
                .padding(.horizontal)

            Chart(monthlyChartData) { data in
                BarMark(
                    x: .value("月份", data.label),
                    y: .value("金額", NSDecimalNumber(decimal: data.amount).doubleValue)
                )
                .foregroundStyle(Color.blue.gradient)
                .cornerRadius(5)
                .annotation(position: .top, alignment: .center) {
                    if data.amount > 0 {
                        Text(data.amount.formatted(.currency(code: primaryCurrency).precision(.fractionLength(0))))
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(Decimal(v).formatted(.currency(code: primaryCurrency).precision(.fractionLength(0))))
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 220)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Yearly Trend

    private var yearlyTrendData: [MonthlySpending] {
        let calendar = Calendar.current
        let now = Date()

        var totals: [Date: Decimal] = [:]

        for sub in allSubscriptions where sub.status != .cancelled {
            guard
                let elevenMonthsAgo = calendar.date(byAdding: .month, value: -11, to: now),
                let monthStart = calendar.date(
                    from: calendar.dateComponents([.year, .month], from: elevenMonthsAgo)
                )
            else { continue }

            let dates = calculator.paymentDates(
                firstPaymentDate: sub.firstPaymentDate,
                billingCycle: sub.billingCycle,
                through: now
            )

            for date in dates where date >= monthStart {
                guard let key = calendar.date(
                    from: calendar.dateComponents([.year, .month], from: date)
                ) else { continue }
                totals[key, default: .zero] += amountForChart(sub)
            }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "M月"

        return (0..<12).reversed().compactMap { offset -> MonthlySpending? in
            guard
                let monthDate = calendar.date(byAdding: .month, value: -offset, to: now),
                let key = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))
            else { return nil }
            return MonthlySpending(label: formatter.string(from: monthDate), amount: totals[key] ?? .zero)
        }
    }

    @ViewBuilder
    private var yearlyTrendCard: some View {
        let nonZero = yearlyTrendData.filter { $0.amount > 0 }
        if !nonZero.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("年度支出趨勢（近 12 個月）")
                    .font(.headline)
                    .padding(.horizontal)

                Chart(yearlyTrendData) { data in
                    AreaMark(
                        x: .value("月份", data.label),
                        y: .value("金額", NSDecimalNumber(decimal: data.amount).doubleValue)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .purple.opacity(0.05)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    LineMark(
                        x: .value("月份", data.label),
                        y: .value("金額", NSDecimalNumber(decimal: data.amount).doubleValue)
                    )
                    .foregroundStyle(.purple)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    PointMark(
                        x: .value("月份", data.label),
                        y: .value("金額", NSDecimalNumber(decimal: data.amount).doubleValue)
                    )
                    .foregroundStyle(.purple)
                    .symbolSize(20)
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text(Decimal(v).formatted(.currency(code: primaryCurrency).precision(.fractionLength(0))))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: 1)) { value in
                        if let label = value.as(String.self) {
                            AxisValueLabel {
                                Text(label).font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: 180)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal)
        }
    }

    // MARK: - Category Chart

    private struct CategorySlice: Identifiable {
        let id = UUID()
        let name: String
        let amount: Decimal
        let colorHex: String
    }

    private var categoryData: [CategorySlice] {
        let catColors: [String: String] = Dictionary(
            uniqueKeysWithValues: ServicePresetLibrary.defaultCategories.map { ($0.name, $0.colorHex) }
        )
        var map: [String: (Decimal, String)] = [:]
        for sub in activeSubscriptions {
            let key = sub.category?.name ?? "其他"
            let colorHex = sub.category?.colorHex ?? catColors["其他"] ?? "#8E8E93"
            let monthly = monthlyInPrimary(sub)
            if let existing = map[key] {
                map[key] = (existing.0 + monthly, existing.1)
            } else {
                map[key] = (monthly, colorHex)
            }
        }
        return map.map { CategorySlice(name: $0.key, amount: $0.value.0, colorHex: $0.value.1) }
            .filter { $0.amount > 0 }
            .sorted { $0.amount > $1.amount }
    }

    private var categoryChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分類支出")
                .font(.headline)
                .padding(.horizontal)

            Chart(categoryData) { slice in
                SectorMark(
                    angle: .value("金額", NSDecimalNumber(decimal: slice.amount).doubleValue),
                    innerRadius: .ratio(0.55),
                    angularInset: 2
                )
                .foregroundStyle(Color(hex: slice.colorHex))
                .cornerRadius(4)
                .accessibilityLabel("\(slice.name): \(slice.amount.formatted(.currency(code: primaryCurrency).precision(.fractionLength(0))))")
            }
            .chartLegend(.hidden)
            .frame(height: 200)
            .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(categoryData) { slice in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: slice.colorHex))
                            .frame(width: 12, height: 12)
                        Text(slice.name)
                            .font(.subheadline)
                        Spacer()
                        Text(slice.amount.formatted(.currency(code: primaryCurrency).precision(.fractionLength(0))))
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Top Subscriptions

    private var sortedByMonthly: [Subscription] {
        activeSubscriptions.sorted { lhs, rhs in
            let l = viewMode == .myShare ? shareCalculator.myMonthlyShare(for: lhs) : calculator.monthlyEquivalent(amount: lhs.amount, cycle: lhs.billingCycle)
            let r = viewMode == .myShare ? shareCalculator.myMonthlyShare(for: rhs) : calculator.monthlyEquivalent(amount: rhs.amount, cycle: rhs.billingCycle)
            return l > r
        }
    }

    private var topSubscriptionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("支出排行")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(Array(sortedByMonthly.prefix(5).enumerated()), id: \.offset) { idx, sub in
                    HStack(spacing: 12) {
                        Text("\(idx + 1)")
                            .font(.caption.weight(.bold).monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 18, alignment: .center)
                        BrandIconView(name: sub.name, colorHex: sub.brandColorHex, iconAssetName: sub.iconAssetName, size: 32)
                        Text(sub.name)
                            .font(.subheadline)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(sub.amount.formatted(.currency(code: sub.currency)))
                                .font(.subheadline.weight(.medium))
                            Text(sub.billingCycle.displayName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(idx + 1) 名：\(sub.name)，\(sub.amount.formatted(.currency(code: sub.currency)))，\(sub.billingCycle.displayName)")

                    if idx < min(sortedByMonthly.count, 5) - 1 {
                        Divider().padding(.leading, 58)
                    }
                }
            }
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("尚無訂閱資料", systemImage: "chart.bar")
        } description: {
            Text("新增訂閱後即可查看統計圖表")
        }
    }
}

// MARK: - Summary Tile

private struct StatSummaryTile: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.subheadline.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title)：\(value)")
    }
}

#Preview {
    NavigationStack { StatisticsView() }
        .modelContainer(
            for: [Subscription.self, SubscriptionCategory.self, PaymentRecord.self,
                  PriceHistoryEntry.self, Friend.self, SharedPlan.self,
                  Contribution.self, SettlementRecord.self],
            inMemory: true
        )
}
