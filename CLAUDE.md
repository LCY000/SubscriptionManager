# CLAUDE.md

Guidance for Claude Code working in this repository.

## 先讀這些

- **[`PLAN.md`](./PLAN.md)** — 完整實作計畫（Context、四個 Phase、資料模型、畫面、里程碑、陷阱預警）。動工前先讀。
- **[`README.md`](./README.md)** — 專案總覽。

## 專案本質

**個人訂閱管理 App**，期末專案。差異化賣點是 **家庭方案分帳**（預付月份抵扣、一鍵催款）。零第三方依賴，全 iOS 原生 API。

## Build & Run

```bash
xcodebuild -scheme "Final Project 2" -configuration Debug \
  -destination "platform=iOS Simulator,name=iPhone 17" build

xcodebuild -scheme "Final Project 2" -configuration Debug \
  -destination "platform=iOS Simulator,name=iPhone 17" test
```

## Project Configuration

- **Bundle ID:** `work.Final-Project-2`
- **iOS Deployment Target:** 26.2（可放心用最新 API）
- **Swift:** 5.0 with `SWIFT_APPROACHABLE_CONCURRENCY`, `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY`
- **Info.plist:** Auto-generated（`GENERATE_INFOPLIST_FILE = YES`）— 不要建立手動 Info.plist
- **Code Signing:** Automatic, team `X2AWFYCC2H`

## 技術棧（已定案）

| 層 | 選擇 |
|---|---|
| UI | SwiftUI（**不用** UIKit） |
| 狀態 | `@Observable` macro（**不用** `ObservableObject`） |
| 資料 | **SwiftData** `@Model`（**不用** CoreData） |
| 同步 | CloudKit via SwiftData（Phase 4） |
| 通知 | UserNotifications |
| 圖表 | Swift Charts |
| Widget | WidgetKit |
| 捷徑 | App Intents |
| 安全 | LocalAuthentication |
| 在地化 | String Catalogs（`.xcstrings`） |

**零第三方套件** — 沒有 SPM / CocoaPods / Carthage。不要加。

## 專案結構約定

```
Final Project 2/
├── App/Final_Project_2App.swift    # @main, ModelContainer 注入
├── Models/                          # SwiftData @Model
├── Services/                        # 邏輯層（週期計算、結算、通知排程）
├── Views/{Home,Subscriptions,Friends,Statistics,Settings,Components,Onboarding}/
├── Widgets/                         # Phase 4
├── Intents/                         # Phase 4
└── Resources/Assets.xcassets, Localizable.xcstrings
Tests/                               # Unit tests
```

新增檔案時遵守此結構。不要把 View 丟 `Models/` 或反過來。

## 寫 Code 約定

- **Views：** 小而單一職責。容器（資料存取）與展示（純 UI）分離。
- **SwiftData：** `@Query` 直接在 View 層取資料沒關係，但複雜過濾 / 計算抽到 Service。
- **Service：** 純 struct / final class，可測、無 side effect。不要偷存 SwiftData context（透過參數注入）。
- **Observable：** ViewModel 用 `@Observable final class`，view 用 `@State` 或 `@Bindable` 持有。
- **繁中為主介面：** 字串走 String Catalog，**不要** 寫死 `"訂閱"` 在 View 裡，用 `Text("subscription.title")` + catalog。
- **Decimal，不用 Double：** 金錢一律 `Decimal`。
- **Date：** 比較 / 計算一律用 `Calendar.current` + timezone-aware，不要用 `Date().timeIntervalSince1970` 湊。
- **Enum with associated values：** 需要 `Codable` 時加 `enum BillingCycle: Codable`，SwiftData 支援。
- **Preview：** 每個 View 提供 `#Preview` 並注入 mock ModelContainer（in-memory）。

## 開發陷阱（來自 PLAN.md 第 7 節）

- **月底週期：** 31 號訂閱 → 下月 28/29/30 要靠 `Calendar.date(byAdding:)` 處理，寫測試覆蓋閏年 2/29
- **時區：** 一律用當前時區 start-of-day
- **通知去重：** `UNNotificationRequest.identifier = "sub_\(id)_\(scheduleDate)"`，更新訂閱時 remove + re-add
- **SwiftData migration：** 盡量只加欄位不改型別；改型別需寫 `MigrationStage`
- **Xcode capability：** Widget 需新 target、iCloud 需在 Signing & Capabilities 加（可能要手動在 Xcode UI 點）

## 實作分工（Opus vs Sonnet）

高階架構、資料模型、核心演算法（BillingCycleCalculator、ContributionSettler）與其測試建議由 Opus 定下來；之後 SwiftUI views、UI 打磨、預設服務庫資料、Widget views、CSV 匯出、設定頁等重複性高的工作可交給 Sonnet 推進。跨 Phase 收尾前回頭 review 架構一致性。

## 當前進度

- [x] 完整實作計畫定案（見 `PLAN.md`）
- [x] **Phase 1 — MVP 核心**（✅ 2026-04-21 完成）
- [x] **Phase 2 — 分帳旗艦**（✅ 2026-04-21 完成）
- [x] **Phase 3 — 視覺化**（✅ 2026-04-22 完成）
- [x] **Phase 4 — 進階整合**（✅ 2026-04-25 完成）

動工前務必先讀 `PLAN.md` 該 Phase 的勾選項以對齊範圍。

## 已知注意事項（跨 Phase 有效）

- **SourceKit 假警報**：大量「Cannot find type」是跨檔案索引問題，`xcodebuild` 實際都能過，不要改程式碼。
- **`Category` 命名衝突**：已改名為 `SubscriptionCategory`，避免與 iOS SDK 衝突。
- **通知識別碼格式**：`sub_{UUID}_{Unix timestamp}`，更新訂閱時 `ReminderScheduler` 自動 remove + re-add。
- **`Tab` API**：使用 iOS 26 新版 `Tab(_, systemImage:, value:)` 而非舊版 `tabItem()`。
