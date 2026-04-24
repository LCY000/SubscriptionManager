import SwiftUI
import SwiftData

struct FriendsListView: View {
    @Query(sort: \Friend.name) private var friends: [Friend]
    @State private var showingAddSheet = false
    @State private var friendToDelete: Friend?
    @Environment(\.modelContext) private var modelContext

    private var totalOutstanding: Decimal {
        friends.reduce(.zero) { sum, f in
            sum + ContributionSettlerService.totalOutstanding(for: f.contributions)
        }
    }

    var body: some View {
        Group {
            if friends.isEmpty {
                ContentUnavailableView {
                    Label("尚無朋友", systemImage: "person.2")
                } description: {
                    Text("新增朋友後可記錄家庭方案分帳、預付月份、一鍵催款")
                } actions: {
                    Button("新增朋友", action: openAddSheet)
                }
            } else {
                List {
                    if totalOutstanding > 0 {
                        Section {
                            HStack {
                                Label("未收款總計", systemImage: "creditcard.trianglebadge.exclamationmark")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(totalOutstanding.formatted(.currency(code: "TWD")))
                                    .font(.headline)
                                    .foregroundStyle(.red)
                            }
                        }
                    }

                    Section("朋友清單（\(friends.count) 人）") {
                        ForEach(friends) { friend in
                            NavigationLink(value: friend) {
                                FriendRowView(friend: friend)
                            }
                        }
                        .onDelete { offsets in
                            guard let first = offsets.first else { return }
                            friendToDelete = friends[first]
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("分帳")
        .navigationDestination(for: Friend.self) { friend in
            FriendDetailView(friend: friend)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("新增朋友", systemImage: "plus", action: openAddSheet)
            }
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            FriendEditView()
        }
        .confirmationDialog(
            "刪除朋友「\(friendToDelete?.name ?? "")」？",
            isPresented: Binding(get: { friendToDelete != nil }, set: { if !$0 { friendToDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button("刪除", role: .destructive) {
                if let friend = friendToDelete {
                    modelContext.delete(friend)
                }
                friendToDelete = nil
            }
            Button("取消", role: .cancel) { friendToDelete = nil }
        } message: {
            Text("所有相關分帳紀錄也會一併刪除，此操作無法復原。")
        }
    }

    private func openAddSheet() {
        showingAddSheet = true
    }


}

#Preview {
    NavigationStack {
        FriendsListView()
    }
    .modelContainer(
        for: [Subscription.self, SubscriptionCategory.self, PaymentRecord.self,
              PriceHistoryEntry.self, Friend.self, SharedPlan.self,
              Contribution.self, SettlementRecord.self],
        inMemory: true
    )
}
