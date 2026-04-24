import SwiftUI
import SwiftData

struct FriendDetailView: View {
    @Bindable var friend: Friend
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var selectedContributionForReminder: Contribution?
    @State private var selectedContributionForPrepay: Contribution?

    private var sortedContributions: [Contribution] {
        friend.contributions.sorted {
            $0.currentStatus.sortPriority < $1.currentStatus.sortPriority
        }
    }

    private var totalOutstanding: Decimal {
        ContributionSettlerService.totalOutstanding(for: friend.contributions)
    }

    var body: some View {
        List {
            if totalOutstanding > 0 {
                Section {
                    HStack {
                        Text("未收款總計")
                            .font(.headline)
                        Spacer()
                        Text(totalOutstanding.formatted(.currency(code: "TWD")))
                            .font(.title3.bold())
                            .foregroundStyle(.red)
                    }
                    .padding(.vertical, 4)
                }
            }

            if !friend.paymentInfo.isEmpty || !friend.note.isEmpty {
                Section("付款資訊") {
                    if !friend.paymentInfo.isEmpty {
                        LabeledContent("付款方式", value: friend.paymentInfo)
                    }
                    if !friend.note.isEmpty {
                        LabeledContent("備註", value: friend.note)
                    }
                }
            }

            Section("訂閱分帳") {
                if sortedContributions.isEmpty {
                    Text("尚未加入任何共享方案")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedContributions) { contribution in
                        ContributionRowView(
                            contribution: contribution,
                            onRemind: { selectedContributionForReminder = contribution },
                            onPaid: { markAsPaid(contribution) },
                            onAddPrepay: { selectedContributionForPrepay = contribution }
                        )
                    }
                }
            }

            Section("結算記錄") {
                let allHistory = sortedContributions
                    .flatMap(\.history)
                    .sorted { $0.settledAt > $1.settledAt }

                if allHistory.isEmpty {
                    Text("尚無結算記錄")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(allHistory.prefix(10)) { record in
                        SettlementRecordRow(record: record)
                    }
                }
            }
        }
        .navigationTitle(friend.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("選項", systemImage: "ellipsis.circle") {
                    Button("編輯朋友", systemImage: "pencil") {
                        showingEditSheet = true
                    }
                    Button("刪除朋友", systemImage: "trash", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            FriendEditView(friend: friend)
        }
        .sheet(item: $selectedContributionForPrepay, content: AddPrepaySheet.init)
        .sheet(item: $selectedContributionForReminder) { contribution in
            ReminderMessageSheet(
                friend: friend,
                subscriptionName: contribution.sharedPlan?.subscription?.name ?? "訂閱",
                amount: contribution.amountPerMonth,
                currency: "TWD"
            )
        }
        .confirmationDialog(
            "確認刪除「\(friend.name)」？此操作將同時移除所有分帳記錄。",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("刪除", role: .destructive, action: deleteFriend)
        }
        .task {
            catchUpAllContributions()
        }
    }

    private func catchUpAllContributions() {
        for contribution in friend.contributions {
            ContributionSettlerService.catchUpToCurrentMonth(
                contribution: contribution,
                context: modelContext
            )
        }
    }

    private func markAsPaid(_ contribution: Contribution) {
        ContributionSettlerService.markAsPaid(contribution: contribution, context: modelContext)
    }

    private func deleteFriend() {
        modelContext.delete(friend)
    }
}

private struct SettlementRecordRow: View {
    let record: SettlementRecord

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(record.periodStart.formatted(.dateTime.year().month()))
                    .font(.subheadline)
                Text(outcomeLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(record.amount.formatted(.currency(code: "TWD")))
                .font(.subheadline)
                .foregroundStyle(record.outcome == .unpaid ? Color.orange : Color.primary)
        }
    }

    private var outcomeLabel: String {
        switch record.outcome {
        case .paidFromPrepay: "預付扣抵"
        case .paidByHand:     "手動記錄"
        case .unpaid:         "未付款"
        }
    }
}

extension ContributionStatus {
    fileprivate var sortPriority: Int {
        switch self {
        case .overdue:  0
        case .unpaid:   1
        case .prepaid:  2
        case .paid:     3
        }
    }
}

