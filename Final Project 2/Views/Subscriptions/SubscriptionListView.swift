import SwiftUI
import SwiftData

struct SubscriptionListView: View {
    @Query(sort: \Subscription.name) private var subscriptions: [Subscription]
    @Query(sort: \SubscriptionCategory.sortOrder) private var categories: [SubscriptionCategory]

    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var showingFilterSheet = false
    @State private var filterStatus: SubscriptionStatus? = nil
    @State private var filterCategory: SubscriptionCategory? = nil
    @State private var sortOrder: SubscriptionSortOrder = .nextPayment
    @State private var filterMinAmount: String = ""
    @State private var filterMaxAmount: String = ""
    @State private var showCancelled = false

    private let calculator = BillingCycleCalculator()

    private var isFiltered: Bool {
        filterStatus != nil || filterCategory != nil || sortOrder != .nextPayment
        || !filterMinAmount.isEmpty || !filterMaxAmount.isEmpty
    }

    private var filtered: [Subscription] {
        var result = subscriptions

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        if let status = filterStatus {
            result = result.filter { $0.status == status }
        }
        if let category = filterCategory {
            result = result.filter { $0.category?.id == category.id }
        }
        if let min = Decimal(string: filterMinAmount), min > .zero {
            result = result.filter { $0.amount >= min }
        }
        if let max = Decimal(string: filterMaxAmount), max > .zero {
            result = result.filter { $0.amount <= max }
        }

        switch sortOrder {
        case .nextPayment:
            result.sort {
                calculator.daysUntilNextPayment(firstPaymentDate: $0.firstPaymentDate, billingCycle: $0.billingCycle) <
                calculator.daysUntilNextPayment(firstPaymentDate: $1.firstPaymentDate, billingCycle: $1.billingCycle)
            }
        case .amountDesc:
            result.sort {
                calculator.monthlyEquivalent(amount: $0.amount, cycle: $0.billingCycle) >
                calculator.monthlyEquivalent(amount: $1.amount, cycle: $1.billingCycle)
            }
        case .name:
            result.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        }

        return result
    }

    // 主動篩選「已取消」時直接顯示全部；否則把已取消分離到 DisclosureGroup
    private var filteredActive: [Subscription] {
        filterStatus == .cancelled ? filtered : filtered.filter { $0.status != .cancelled }
    }

    private var filteredCancelled: [Subscription] {
        filterStatus == .cancelled ? [] : filtered.filter { $0.status == .cancelled }
    }

    // Grouping only applies when sorting by next payment and no status filter
    private var useGrouping: Bool {
        sortOrder == .nextPayment && filterStatus == nil
    }

    private func group(_ subs: [Subscription]) -> [(title: String, items: [Subscription])] {
        let upcoming = subs.filter {
            ($0.status == .active || $0.status == .trial) &&
            calculator.daysUntilNextPayment(firstPaymentDate: $0.firstPaymentDate, billingCycle: $0.billingCycle) <= 7
        }
        let active = subs.filter {
            ($0.status == .active || $0.status == .trial) &&
            calculator.daysUntilNextPayment(firstPaymentDate: $0.firstPaymentDate, billingCycle: $0.billingCycle) > 7
        }
        let paused = subs.filter { $0.status == .paused }
        let cancelled = subs.filter { $0.status == .cancelled }

        var groups: [(String, [Subscription])] = []
        if !upcoming.isEmpty  { groups.append(("即將扣款", upcoming)) }
        if !active.isEmpty    { groups.append(("啟用中", active)) }
        if !paused.isEmpty    { groups.append(("已暫停", paused)) }
        if !cancelled.isEmpty { groups.append(("已取消", cancelled)) }
        return groups
    }

    var body: some View {
        Group {
            if subscriptions.isEmpty {
                ContentUnavailableView {
                    Label("尚無訂閱", systemImage: "creditcard")
                } description: {
                    Text("點選右上角 + 號新增第一筆訂閱")
                } actions: {
                    Button("新增訂閱") { showingAddSheet = true }
                }
            } else if filtered.isEmpty {
                if searchText.isEmpty {
                    ContentUnavailableView {
                        Label("無符合的訂閱", systemImage: "line.3.horizontal.decrease.circle")
                    } description: {
                        Text("請調整篩選條件")
                    } actions: {
                        Button("清除篩選") {
                            filterStatus = nil
                            filterCategory = nil
                            sortOrder = .nextPayment
                        }
                    }
                } else {
                    ContentUnavailableView.search(text: searchText)
                }
            } else {
                List {
                    if useGrouping {
                        ForEach(group(filteredActive), id: \.title) { section in
                            Section(section.title) {
                                ForEach(section.items) { subscription in
                                    NavigationLink(value: subscription) {
                                        SubscriptionRowView(subscription: subscription)
                                    }
                                }
                            }
                        }
                    } else {
                        ForEach(filteredActive) { subscription in
                            NavigationLink(value: subscription) {
                                SubscriptionRowView(subscription: subscription)
                            }
                        }
                    }

                    if !filteredCancelled.isEmpty {
                        Section {
                            DisclosureGroup(isExpanded: $showCancelled) {
                                ForEach(filteredCancelled) { subscription in
                                    NavigationLink(value: subscription) {
                                        SubscriptionRowView(subscription: subscription)
                                    }
                                }
                            } label: {
                                Label("已取消（\(filteredCancelled.count)）", systemImage: "xmark.circle")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("訂閱")
        .searchable(text: $searchText, prompt: "搜尋訂閱名稱")
        .navigationDestination(for: Subscription.self) { subscription in
            SubscriptionDetailView(subscription: subscription)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("新增訂閱", systemImage: "plus") { showingAddSheet = true }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingFilterSheet = true
                } label: {
                    Image(systemName: isFiltered ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundStyle(isFiltered ? .blue : .primary)
                }
                .accessibilityLabel(isFiltered ? "篩選中，點擊修改" : "篩選")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            SubscriptionEditView()
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheet(
                categories: categories,
                filterStatus: $filterStatus,
                filterCategory: $filterCategory,
                sortOrder: $sortOrder,
                filterMinAmount: $filterMinAmount,
                filterMaxAmount: $filterMaxAmount
            )
        }
    }
}

// MARK: - Sort Order

private enum SubscriptionSortOrder: String, CaseIterable, Identifiable {
    case nextPayment, amountDesc, name
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .nextPayment: "下次扣款日"
        case .amountDesc:  "金額（高到低）"
        case .name:        "名稱"
        }
    }
}

// MARK: - Filter Sheet

private struct FilterSheet: View {
    let categories: [SubscriptionCategory]
    @Binding var filterStatus: SubscriptionStatus?
    @Binding var filterCategory: SubscriptionCategory?
    @Binding var sortOrder: SubscriptionSortOrder
    @Binding var filterMinAmount: String
    @Binding var filterMaxAmount: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("排序") {
                    ForEach(SubscriptionSortOrder.allCases) { order in
                        Button {
                            sortOrder = order
                        } label: {
                            HStack {
                                Text(order.displayName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                Section("狀態") {
                    Button {
                        filterStatus = nil
                    } label: {
                        HStack {
                            Text("全部")
                                .foregroundStyle(.primary)
                            Spacer()
                            if filterStatus == nil {
                                Image(systemName: "checkmark").foregroundStyle(.blue)
                            }
                        }
                    }
                    ForEach(SubscriptionStatus.allCases, id: \.self) { status in
                        Button {
                            filterStatus = (filterStatus == status) ? nil : status
                        } label: {
                            HStack {
                                Label(status.displayName, systemImage: status.iconName)
                                    .foregroundStyle(status.accentColor)
                                Spacer()
                                if filterStatus == status {
                                    Image(systemName: "checkmark").foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                if !categories.isEmpty {
                    Section("分類") {
                        Button {
                            filterCategory = nil
                        } label: {
                            HStack {
                                Text("全部分類")
                                    .foregroundStyle(.primary)
                                Spacer()
                                if filterCategory == nil {
                                    Image(systemName: "checkmark").foregroundStyle(.blue)
                                }
                            }
                        }
                        ForEach(categories) { cat in
                            Button {
                                filterCategory = (filterCategory?.id == cat.id) ? nil : cat
                            } label: {
                                HStack {
                                    Label(cat.name, systemImage: cat.iconName)
                                        .foregroundStyle(Color(hex: cat.colorHex))
                                    Spacer()
                                    if filterCategory?.id == cat.id {
                                        Image(systemName: "checkmark").foregroundStyle(.blue)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("金額範圍") {
                    HStack {
                        Text("最低")
                            .foregroundStyle(.secondary)
                            .frame(width: 36, alignment: .leading)
                        TextField("0", text: $filterMinAmount)
                            .keyboardType(.decimalPad)
                        Text("TWD")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    HStack {
                        Text("最高")
                            .foregroundStyle(.secondary)
                            .frame(width: 36, alignment: .leading)
                        TextField("不限", text: $filterMaxAmount)
                            .keyboardType(.decimalPad)
                        Text("TWD")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        filterStatus = nil
                        filterCategory = nil
                        sortOrder = .nextPayment
                        filterMinAmount = ""
                        filterMaxAmount = ""
                    } label: {
                        Text("清除篩選條件")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("篩選與排序")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成", action: dismiss.callAsFunction)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SubscriptionListView()
    }
    .modelContainer(
        for: [Subscription.self, SubscriptionCategory.self, PaymentRecord.self,
              PriceHistoryEntry.self, Friend.self, SharedPlan.self,
              Contribution.self, SettlementRecord.self],
        inMemory: true
    )
}
