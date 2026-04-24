import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = AppTab.home
    @Environment(\.modelContext) private var modelContext
    @Query private var subscriptions: [Subscription]

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("首頁", systemImage: "house.fill", value: AppTab.home) {
                NavigationStack {
                    HomeView(selectTab: { selectedTab = $0 })
                }
            }
            Tab("訂閱", systemImage: "creditcard.fill", value: AppTab.subscriptions) {
                NavigationStack {
                    SubscriptionListView()
                }
            }
            Tab("分帳", systemImage: "person.2.fill", value: AppTab.friends) {
                NavigationStack {
                    FriendsListView()
                }
            }
            Tab("統計", systemImage: "chart.bar.fill", value: AppTab.statistics) {
                NavigationStack {
                    StatisticsView()
                }
            }
            Tab("設定", systemImage: "gearshape.fill", value: AppTab.settings) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
            OnboardingView()
        }
        .task {
            await seedCategoriesIfNeeded()
        }
        .onChange(of: subscriptions.count) { _, _ in
            WidgetRefresher.refresh(subscriptions: subscriptions)
        }
        .onAppear {
            WidgetRefresher.refresh(subscriptions: subscriptions)
        }
    }

    @MainActor
    private func seedCategoriesIfNeeded() async {
        let descriptor = FetchDescriptor<SubscriptionCategory>()
        let existing = (try? modelContext.fetch(descriptor)) ?? []
        let existingNames = Set(existing.map { $0.name })
        for meta in ServicePresetLibrary.defaultCategories where !existingNames.contains(meta.name) {
            modelContext.insert(SubscriptionCategory(
                name: meta.name,
                iconName: meta.iconName,
                colorHex: meta.colorHex,
                sortOrder: meta.sortOrder
            ))
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [
                Subscription.self,
                SubscriptionCategory.self,
                PaymentRecord.self,
                PriceHistoryEntry.self,
                Friend.self,
                SharedPlan.self,
                Contribution.self,
                SettlementRecord.self,
            ],
            inMemory: true
        )
}
