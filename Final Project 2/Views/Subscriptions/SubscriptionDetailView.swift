import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    let subscription: Subscription
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingSharedPlanSheet = false
    @State private var showingCancelConfirmation = false

    private let calculator = BillingCycleCalculator()
    private let shareCalculator = SubscriptionShareCalculator()

    private var nextPaymentDate: Date {
        calculator.nextPaymentDate(
            firstPaymentDate: subscription.firstPaymentDate,
            billingCycle: subscription.billingCycle
        )
    }

    private var myAmount: Decimal { shareCalculator.myAmount(for: subscription) }
    private var hasSharedSplit: Bool { subscription.isShared && myAmount != subscription.amount }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                detailsCard
                statusActionsCard
                sharedPlanCard
                notesCard
                priceHistoryCard
                paymentHistoryCard
                deleteButton
            }
            .padding(.vertical)
        }
        .navigationTitle(subscription.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let url = try? SubscriptionShareEncoder.encode(subscription) {
                    ShareLink(item: url, subject: Text("訂閱方案分享"), message: Text("用訂閱管家匯入「\(subscription.name)」")) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("編輯", action: { showingEditSheet = true })
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            SubscriptionEditView(subscription: subscription)
        }
        .sheet(isPresented: $showingSharedPlanSheet) {
            SharedPlanEditView(subscription: subscription)
        }
        .confirmationDialog(
            "確認取消「\(subscription.name)」？",
            isPresented: $showingCancelConfirmation,
            titleVisibility: .visible
        ) {
            Button("取消訂閱", role: .destructive) { setStatus(.cancelled) }
        } message: {
            Text("取消後訂閱將停止追蹤扣款與提醒")
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 12) {
            BrandIconView(name: subscription.name, colorHex: subscription.brandColorHex, iconAssetName: subscription.iconAssetName, size: 72)

            Text(subscription.name)
                .font(.title2.bold())

            HStack(spacing: 8) {
                Label(subscription.status.displayName, systemImage: subscription.status.iconName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(subscription.status.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(subscription.status.accentColor.opacity(0.15))
                    .clipShape(.capsule)

                if subscription.isShared {
                    let isMine = subscription.isOrganizer
                    Label(
                        isMine ? "我主辦" : "朋友主辦",
                        systemImage: isMine ? "person.2.fill" : "person.fill.checkmark"
                    )
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isMine ? Color.blue : Color.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background((isMine ? Color.blue : Color.purple).opacity(0.15))
                    .clipShape(.capsule)
                }
            }

            if let category = subscription.category {
                Label(category.name, systemImage: category.iconName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Details

    private var detailsCard: some View {
        VStack(spacing: 0) {
            DetailRow(
                label: "方案金額",
                value: subscription.amount.formatted(.currency(code: subscription.currency))
            )
            if hasSharedSplit {
                Divider().padding(.leading)
                DetailRow(
                    label: "我每次付",
                    value: myAmount.formatted(.currency(code: subscription.currency))
                )
            }
            Divider().padding(.leading)
            DetailRow(label: "付款週期", value: subscription.billingCycle.displayName)
            Divider().padding(.leading)
            DetailRow(
                label: "首次扣款",
                value: subscription.firstPaymentDate.formatted(date: .abbreviated, time: .omitted)
            )
            Divider().padding(.leading)
            DetailRow(
                label: "下次扣款",
                value: nextPaymentDate.formatted(date: .abbreviated, time: .omitted)
            )
            if subscription.status == .trial, let trialEnd = subscription.trialEndDate {
                Divider().padding(.leading)
                DetailRow(
                    label: "試用到期",
                    value: trialEnd.formatted(date: .abbreviated, time: .omitted)
                )
            }
            Divider().padding(.leading)
            DetailRow(label: "提前提醒", value: "扣款前 \(subscription.reminderDaysBefore) 天")
        }
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Status Actions

    @ViewBuilder
    private var statusActionsCard: some View {
        switch subscription.status {
        case .active, .trial:
            HStack(spacing: 12) {
                StatusActionButton(label: "暫停", icon: "pause.circle", color: .orange) {
                    setStatus(.paused)
                }
                StatusActionButton(label: "取消訂閱", icon: "xmark.circle", color: .red, isDestructive: true) {
                    showingCancelConfirmation = true
                }
            }
            .padding(.horizontal)

        case .paused:
            HStack(spacing: 12) {
                StatusActionButton(label: "恢復訂閱", icon: "play.circle", color: .green) {
                    setStatus(.active)
                }
                StatusActionButton(label: "取消訂閱", icon: "xmark.circle", color: .red, isDestructive: true) {
                    showingCancelConfirmation = true
                }
            }
            .padding(.horizontal)

        case .cancelled:
            StatusActionButton(label: "重新啟用", icon: "arrow.counterclockwise.circle", color: .blue) {
                setStatus(.active)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Notes / History / Shared Plan

    @ViewBuilder private var notesCard: some View {
        if !subscription.notes.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("備註")
                    .font(.headline)
                    .padding(.horizontal)

                Text(subscription.notes)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 16))
                    .padding(.horizontal)
            }
        }
    }

    @ViewBuilder private var priceHistoryCard: some View {
        let sorted = subscription.priceHistory.sorted { $0.changedAt > $1.changedAt }
        if !sorted.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("價格變動歷史")
                    .font(.headline)
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    ForEach(sorted) { entry in
                        HStack(spacing: 12) {
                            Image(systemName: entry.newAmount > entry.oldAmount ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .foregroundStyle(entry.newAmount > entry.oldAmount ? .red : .green)
                                .font(.title3)
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text(entry.oldAmount.formatted(.currency(code: subscription.currency)))
                                        .strikethrough()
                                        .foregroundStyle(.secondary)
                                    Image(systemName: "arrow.right")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text(entry.newAmount.formatted(.currency(code: subscription.currency)))
                                        .fontWeight(.medium)
                                }
                                .font(.subheadline)
                                Text(entry.changedAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("價格從 \(entry.oldAmount.formatted(.currency(code: subscription.currency))) 調整為 \(entry.newAmount.formatted(.currency(code: subscription.currency)))，\(entry.changedAt.formatted(date: .abbreviated, time: .omitted))")

                        if entry.id != sorted.last?.id {
                            Divider().padding(.leading)
                        }
                    }
                }
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal)
            }
        }
    }

    @ViewBuilder private var paymentHistoryCard: some View {
        if !subscription.paymentRecords.isEmpty {
            PaymentHistorySection(records: subscription.paymentRecords)
        }
    }

    @ViewBuilder private var sharedPlanCard: some View {
        if subscription.isShared && subscription.isOrganizer {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("共享方案成員")
                        .font(.headline)
                    Spacer()
                    Button("設定") { showingSharedPlanSheet = true }
                        .font(.subheadline)
                }
                .padding(.horizontal)

                if let plan = subscription.sharedPlan, !plan.contributions.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(plan.contributions) { contribution in
                            HStack {
                                Text(contribution.friend?.name ?? "未知")
                                    .font(.subheadline)
                                Spacer()
                                Label(
                                    contribution.currentStatus.displayName,
                                    systemImage: contribution.currentStatus.iconName
                                )
                                .font(.caption)
                                .foregroundStyle(contribution.currentStatus.accentColor)
                                Text(contribution.amountPerMonth.formatted(.currency(code: subscription.currency)))
                                    .font(.subheadline)
                                    .frame(width: 70, alignment: .trailing)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            if contribution.id != plan.contributions.last?.id {
                                Divider().padding(.leading)
                            }
                        }
                    }
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 16))
                    .padding(.horizontal)
                } else {
                    Text("尚未設定成員")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Delete

    private var deleteButton: some View {
        Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
            Label("刪除訂閱", systemImage: "trash")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .clipShape(.rect(cornerRadius: 12))
        }
        .padding(.horizontal)
        .confirmationDialog(
            "確認刪除「\(subscription.name)」？此操作無法復原。",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("刪除", role: .destructive, action: deleteSubscription)
        }
    }

    // MARK: - Actions

    private func setStatus(_ newStatus: SubscriptionStatus) {
        subscription.status = newStatus
        Task { await ReminderScheduler.schedule(for: subscription) }
    }

    private func deleteSubscription() {
        let subId = subscription.id
        Task { await ReminderScheduler.cancel(for: subId) }
        modelContext.delete(subscription)
        dismiss()
    }
}

// MARK: - StatusActionButton

private struct StatusActionButton: View {
    let label: String
    let icon: String
    let color: Color
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(color.opacity(0.12))
                .clipShape(.rect(cornerRadius: 12))
        }
        .accessibilityLabel(label)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Subscription.self, SubscriptionCategory.self, PaymentRecord.self,
            PriceHistoryEntry.self, Friend.self, SharedPlan.self,
            Contribution.self, SettlementRecord.self,
        configurations: config
    )
    let sub = Subscription(
        name: "Netflix",
        brandColorHex: "#E50914",
        amount: 390,
        billingCycle: .monthly,
        firstPaymentDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
    )
    container.mainContext.insert(sub)

    return NavigationStack {
        SubscriptionDetailView(subscription: sub)
    }
    .modelContainer(container)
}
