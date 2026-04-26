import SwiftUI
import SwiftData

@main
struct Final_Project_2App: App {
    let modelContainer: ModelContainer
    @AppStorage("appLockEnabled") private var appLockEnabled = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var isLocked = UserDefaults.standard.bool(forKey: "appLockEnabled")
    @State private var importRouter = ImportRouter()

    init() {
        let iCloudEnabled = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
        let schema = Schema([
            Subscription.self,
            SubscriptionCategory.self,
            PaymentRecord.self,
            PriceHistoryEntry.self,
            Friend.self,
            SharedPlan.self,
            Contribution.self,
            SettlementRecord.self,
        ])

        if iCloudEnabled {
            do {
                let config = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
                modelContainer = try ModelContainer(for: schema, configurations: config)
            } catch {
                // CloudKit 未設定或不可用，回退到本地儲存
                modelContainer = try! ModelContainer(for: schema)
            }
        } else {
            modelContainer = try! ModelContainer(for: schema)
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if appLockEnabled && isLocked {
                    AppLockView {
                        isLocked = false
                    }
                } else {
                    ContentView()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background && appLockEnabled {
                    isLocked = true
                }
            }
            .onOpenURL { url in importRouter.handle(url: url) }
            .sheet(
                isPresented: Binding(
                    get: { importRouter.pendingPayload != nil },
                    set: { if !$0 { importRouter.clear() } }
                )
            ) {
                if let payload = importRouter.pendingPayload {
                    ImportSubscriptionView(payload: payload) { importRouter.clear() }
                }
            }
            .alert(
                "匯入失敗",
                isPresented: Binding(
                    get: { importRouter.failureMessage != nil },
                    set: { if !$0 { importRouter.clear() } }
                ),
                presenting: importRouter.failureMessage
            ) { _ in
                Button("好", role: .cancel) { importRouter.clear() }
            } message: { msg in
                Text(msg)
            }
            .environment(importRouter)
        }
        .modelContainer(modelContainer)
    }
}
