import SwiftUI
import SwiftData

struct SharedPlanEditView: View {
    let subscription: Subscription
    @Query(sort: \Friend.name) private var allFriends: [Friend]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var totalMembers: Int = 2
    @State private var useEqualSplit: Bool = true
    @State private var selectedFriendIds: Set<UUID> = []
    @State private var customAmounts: [UUID: String] = [:]

    private var perMemberAmount: Decimal {
        guard totalMembers > 1 else { return subscription.amount }
        var result = subscription.amount / Decimal(totalMembers)
        var rounded = Decimal.zero
        NSDecimalRound(&rounded, &result, 0, .down)
        return rounded
    }

    private var organizerShare: Decimal {
        subscription.amount - perMemberAmount * Decimal(totalMembers - 1)
    }

    private var existingPlan: SharedPlan? { subscription.sharedPlan }

    init(subscription: Subscription) {
        self.subscription = subscription
        if let plan = subscription.sharedPlan {
            _totalMembers = State(initialValue: plan.totalMembers)
            let ids = Set(plan.contributions.compactMap { $0.friend?.id })
            _selectedFriendIds = State(initialValue: ids)
            if case .custom(let shares) = plan.splitMethod {
                var amounts: [UUID: String] = [:]
                for share in shares { amounts[share.friendId] = "\(share.amount)" }
                _customAmounts = State(initialValue: amounts)
                _useEqualSplit = State(initialValue: false)
            }
        }
    }

    var body: some View {
        NavigationStack {
            if !subscription.isOrganizer {
                ContentUnavailableView {
                    Label("此訂閱由朋友主辦", systemImage: "person.fill.checkmark")
                } description: {
                    Text("無法在這個視角設定共享成員，請聯繫主辦人")
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("關閉", action: dismiss.callAsFunction)
                    }
                }
            } else {
                form
            }
        }
    }

    private var form: some View {
        Form {
            Section("方案設定") {
                Stepper("共 \(totalMembers) 人（包含自己）", value: $totalMembers, in: 2...20)
                Toggle("平均分攤", isOn: $useEqualSplit)
                if useEqualSplit {
                    LabeledContent("每人費用") {
                        Text(perMemberAmount.formatted(.currency(code: subscription.currency)))
                            .foregroundStyle(.secondary)
                    }
                    if organizerShare != perMemberAmount {
                        LabeledContent("主辦人實付") {
                            Text(organizerShare.formatted(.currency(code: subscription.currency)))
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }

            Section {
                ForEach(allFriends) { friend in
                    HStack {
                        Image(systemName: selectedFriendIds.contains(friend.id)
                              ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedFriendIds.contains(friend.id) ? Color.accentColor : Color.secondary)
                            .accessibilityHidden(true)

                        Text(friend.name)

                        Spacer()

                        if !useEqualSplit && selectedFriendIds.contains(friend.id) {
                            TextField("金額", text: Binding(
                                get: { customAmounts[friend.id] ?? "" },
                                set: { customAmounts[friend.id] = $0 }
                            ))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        } else if useEqualSplit && selectedFriendIds.contains(friend.id) {
                            Text(perMemberAmount.formatted(.currency(code: subscription.currency)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { toggleFriend(friend) }
                    .accessibilityAddTraits(.isButton)
                }
            } header: {
                Text("選擇成員")
            } footer: {
                Text("勾選要加入這個方案的朋友")
            }
        }
        .navigationTitle("共享方案設定")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消", action: dismiss.callAsFunction)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("儲存", action: save)
                    .fontWeight(.semibold)
                    .disabled(selectedFriendIds.isEmpty)
            }
        }
    }

    private func toggleFriend(_ friend: Friend) {
        if selectedFriendIds.contains(friend.id) {
            selectedFriendIds.remove(friend.id)
        } else {
            selectedFriendIds.insert(friend.id)
        }
    }

    private func save() {
        let plan: SharedPlan
        if let existing = existingPlan {
            plan = existing
            plan.totalMembers = totalMembers
        } else {
            plan = SharedPlan(totalMembers: totalMembers)
            modelContext.insert(plan)
            plan.subscription = subscription
        }

        let splitMethod: SplitMethod = useEqualSplit
            ? .equal
            : .custom(selectedFriendIds.map { id in
                let amt = Decimal(string: customAmounts[id] ?? "") ?? perMemberAmount
                return CustomShare(friendId: id, amount: max(amt, .zero))
            })
        plan.splitMethod = splitMethod

        // Remove contributions for deselected friends
        let toRemove = plan.contributions.filter { c in
            guard let fid = c.friend?.id else { return true }
            return !selectedFriendIds.contains(fid)
        }
        for c in toRemove { modelContext.delete(c) }

        // Add contributions for newly selected friends
        let existingFriendIds = Set(plan.contributions.compactMap { $0.friend?.id })
        for friend in allFriends where selectedFriendIds.contains(friend.id) {
            guard !existingFriendIds.contains(friend.id) else { continue }
            let amount: Decimal = useEqualSplit
                ? perMemberAmount
                : (Decimal(string: customAmounts[friend.id] ?? "") ?? perMemberAmount)
            let contribution = Contribution(amountPerMonth: amount, friend: friend, sharedPlan: plan)
            modelContext.insert(contribution)
        }

        // Update amounts for existing contributions
        for c in plan.contributions {
            guard let fid = c.friend?.id, selectedFriendIds.contains(fid) else { continue }
            c.amountPerMonth = useEqualSplit
                ? perMemberAmount
                : (Decimal(string: customAmounts[fid] ?? "") ?? perMemberAmount)
        }

        dismiss()
    }
}
