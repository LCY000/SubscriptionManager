# 訂閱管理 App 實作計畫

## 1. Context 背景

你的期末專案是要做一款「個人訂閱管理 App」。從你的五張投影片可以看到：

**你已經想到的痛點：**
- 訂閱服務散落不同平台、難以集中掌握
- 常忘記扣款日 / 試用到期日
- 難以統計每月固定支出
- **跟朋友分攤家庭方案（如 Spotify Family）超級麻煩**——投影片 2 你寫得很具體：「林沛妤 210 沒給」「粉 給了 8 個月 2026/7 月再開始」，這是你生活中真實在發生的問題

**我額外補充的痛點與功能建議**（你原本沒列但很關鍵）：

| 補充項目 | 為什麼重要 |
|---|---|
| **預設服務庫**（Netflix、Spotify、YouTube Premium、iCloud+…）含 logo 顏色 | 使用者新增訂閱時不用一個個手打，體感好非常多 |
| **試用期專屬管理**（trial → paid 的自動轉換提醒） | 你投影片提過但沒展開，這是避免「試用完自動扣款」被騙的關鍵 |
| **多種付款週期**：月/季/半年/年/週/自訂天數 | YouTube Premium 有年付、有些 App 有季付，只做月付不夠 |
| **Home Screen Widget** | 一眼看到「本月還要付 NT$ 1,240 / 最近扣款：3 天後 Netflix」 |
| **Siri Shortcuts / App Intents** | 「嘿 Siri，我這個月訂閱花多少？」 |
| **Face ID / Touch ID 鎖** | 財務資料敏感，iOS 26.2 標準安全做法 |
| **iCloud 同步** | 跨 iPhone / iPad 資料一致，SwiftData 原生支援只要一個 flag |
| **付款紀錄 log**（不只下次付款，還留歷史） | 可以看「過去一年我在訂閱上花了 X 元」 |
| **價格變動歷史** | Netflix 每年漲價，記錄下來有感 |
| **暗黑模式 / 動態字體 / VoiceOver** | iOS 課程評分常看這個，做好了是加分項 |
| **繁中在地化** | 雖然預設就是中文，但把金額格式、日期格式、貨幣符號處理對 |
| **匯出 CSV / 分享** | 想報稅或轉到其他工具的出口，做起來 10 行程式碼 |
| **分類 + 標籤**（影音、音樂、外送、生產力、雲端、遊戲…） | 統計「影音類花最多」比單看總額有洞察 |
| **空狀態 / 首次引導 / 錯誤狀態設計** | 學生專案常忽略這塊，但這是「商業 App 感」的分水嶺 |

---

## 2. 目標範圍（旗艦版，分 4 個 Phase）

設計成 **每個 Phase 結束都是可交付版本**。就算時間不夠只做到 Phase 2，也已經是完整實用的 App。

### Phase 1 — MVP 核心（訂閱管理骨幹）✅ 完成
- [x] 資料模型（SwiftData）：`Subscription`, `PaymentRecord`, `SubscriptionCategory`, `Friend`, `SharedPlan`, `Contribution`, `SettlementRecord`
- [x] 訂閱 CRUD：新增 / 編輯 / 刪除 / 查看詳情
- [x] 訂閱列表主頁（按下次扣款日排序，狀態分組：即將扣款 / 啟用中 / 已暫停 / 已取消）
- [x] 付款週期計算（月/季/半年/年/週/自訂）—— 含月底陷阱處理
- [x] 下次扣款日計算與顯示
- [x] 本地通知（UserNotifications）：`ReminderScheduler`，儲存時排程、刪除時取消、通知識別碼去重
- [x] 空狀態畫面（`ContentUnavailableView`）、首次啟動 3 頁引導（`OnboardingView`）
- [x] 單元測試：`BillingCycleCalculatorTests`（13 筆）、`ContributionSettlerTests`（12 筆）

### Phase 2 — 分帳旗艦功能（差異化賣點）✅ 完成
- [x] 資料模型擴充：`Friend`, `SharedPlan`, `Contribution`, `SettlementRecord`（Opus 預建）
- [x] 一個訂閱可標記為「家庭/共享方案」並設定共用人數與拆帳金額（`SharedPlanEditView`）
- [x] 朋友名單管理（`FriendsListView` + `FriendEditView`，含姓名/LINE ID/銀行末5碼）
- [x] **預付月份邏輯**：`ContributionSettlerService.addPrepay()`，`AddPrepaySheet` UI，月度自動 catch-up
- [x] 每位朋友的對帳狀態：`FriendDetailView` 顯示已付/預付剩N月/未付/逾期，`ContributionRowView`
- [x] **一鍵催款**：`ReminderMessageSheet`，可自訂文案，ShareLink 分享到 LINE/iMessage
- [x] 分帳歷史紀錄：`SettlementRecordRow` 顯示結算歷程（預付扣抵/手動/未付）
- [x] 「有人欠我多少」總覽卡片：`OwedSummaryCard`，整合至首頁

### Phase 3 — 視覺化與體感 ✅ 完成
- [x] **Swift Charts**：月度支出長條圖（近 6 個月 BarMark）、年度趨勢（近 12 個月 LineMark + AreaMark）、分類圓餅圖（SectorMark）
- [x] 年度訂閱總支出儀表板（3 張 summary tile：本月預估 / 年度預估 / 訂閱數）
- [x] 分類系統（內建影音/音樂/遊戲/生產力/雲端儲存/外送/其他，可自訂：`CategoryManagementView` + `CategoryEditView`，設定頁入口）
- [x] **預設服務庫**：23 個常見服務（`ServicePresetLibrary`），`ServicePresetPickerView` 分類橫選 UI，新增訂閱一鍵帶入
- [x] 搜尋 + 篩選（按類別 / 狀態 / 金額範圍，`FilterSheet`）
- [x] 試用期管理：標記為試用 + 試用到期提醒（最少提前 2 天，`ReminderScheduler.scheduleTrialReminder`）
- [x] 付費訂閱的「暫停 / 恢復 / 取消 / 重新啟用」狀態管理（`SubscriptionDetailView` 狀態操作列）
- [x] 暗黑模式完整支援（SwiftUI `.regularMaterial` + 系統色）、Dynamic Type（系統字體）、VoiceOver label（`accessibilityLabel` + `accessibilityElement`）

### Phase 4 — 進階 iOS 整合（完整度加分）✅ 完成
- [x] **Home Screen Widget**（WidgetKit + Timeline）：小尺寸顯示本月總支出、中尺寸顯示最近 3 筆即將扣款
- [x] **App Intents / Siri Shortcuts**：「這個月訂閱花多少」「下一筆扣款是什麼」
- [x] **iCloud 同步**（SwiftData + CloudKit）：設定頁開關，重啟後生效（需 Xcode iCloud capability）
- [x] **Face ID / Touch ID 應用程式鎖**（LocalAuthentication）
- [x] **CSV 匯出**（ShareLink）
- [x] **價格變動歷史**：編輯金額時自動紀錄，在詳情頁顯示歷史
- [x] **多幣別支援**（TWD / USD / JPY / EUR），首頁與統計統一換算成主幣別

---

## 3. 技術架構

| 層 | 技術 | 說明 |
|---|---|---|
| UI | SwiftUI（iOS 26.2 target） | 純 SwiftUI，不用 UIKit |
| State | `@Observable` macro（Swift 5.9+） | 取代 ObservableObject |
| 資料 | **SwiftData**（`@Model`） | 取代 CoreData；iOS 17+ 原生，與 SwiftUI 極佳整合 |
| 同步 | CloudKit（via SwiftData） | Phase 4，只要在 ModelContainer 上開一個 flag |
| 通知 | UserNotifications | 扣款提醒、試用到期提醒 |
| 圖表 | Swift Charts | Phase 3 |
| Widget | WidgetKit + TimelineProvider | Phase 4（新 target） |
| Shortcuts | AppIntents framework | Phase 4 |
| 安全 | LocalAuthentication | Phase 4 |
| 在地化 | String Catalogs (`.xcstrings`) | 繁中為主，預留英文 |

**不需要：** 後端 server、帳號系統、CocoaPods/SPM 第三方套件（全部 iOS 原生 API 可達成）

---

## 4. 資料模型設計（SwiftData）

```swift
@Model final class Subscription {
    var id: UUID
    var name: String                    // "Spotify 家庭方案"
    var iconAssetName: String?          // 預設服務庫對應 / nil 用色塊
    var brandColorHex: String           // 品牌色
    var amount: Decimal                 // 總金額
    var currency: String                // "TWD"
    var billingCycle: BillingCycle      // .monthly / .yearly / .custom(days)
    var firstPaymentDate: Date          // 第一次扣款日
    var category: Category?
    var status: SubscriptionStatus      // .active / .paused / .cancelled / .trial
    var trialEndDate: Date?             // 試用期結束日
    var notes: String
    var reminderDaysBefore: Int         // 預設 1
    var isShared: Bool                  // 是否為共享方案
    var sharedPlan: SharedPlan?         // 分帳資訊
    @Relationship(deleteRule: .cascade) var paymentRecords: [PaymentRecord]
    @Relationship(deleteRule: .cascade) var priceHistory: [PriceHistoryEntry]
    var createdAt: Date
}

enum BillingCycle: Codable {
    case weekly, monthly, quarterly, semiAnnual, yearly
    case customDays(Int)
}

enum SubscriptionStatus: String, Codable { case active, paused, cancelled, trial }

@Model final class Category {
    var id: UUID
    var name: String       // "影音串流"
    var iconName: String   // SF Symbol
    var colorHex: String
}

@Model final class Friend {
    var id: UUID
    var name: String
    var paymentInfo: String  // "LINE: @xxx / 中信 ...1234"
    var note: String
    @Relationship(deleteRule: .cascade) var contributions: [Contribution]
}

@Model final class SharedPlan {
    var id: UUID
    var totalMembers: Int
    @Relationship var friends: [Friend]
    var splitMethod: SplitMethod  // .equal / .custom
}

enum SplitMethod: Codable { case equal; case custom([UUID: Decimal]) }

@Model final class Contribution {
    var id: UUID
    var friendId: UUID
    var subscriptionId: UUID
    var amountPerMonth: Decimal
    var prepaidMonthsRemaining: Int  // 預付還剩幾個月
    var lastSettledMonth: Date       // 最後結算到哪個月
    var status: ContributionStatus   // .paid / .prepaid / .unpaid / .overdue
    var history: [SettlementRecord]  // 歷史紀錄
}

@Model final class PaymentRecord {
    var id: UUID
    var subscriptionId: UUID
    var paidDate: Date
    var amount: Decimal
}

@Model final class PriceHistoryEntry {
    var id: UUID
    var subscriptionId: UUID
    var oldAmount: Decimal
    var newAmount: Decimal
    var changedAt: Date
}
```

---

## 5. 畫面與導航架構

**主結構：** `TabView` 底部分頁
1. **首頁**：本月總支出、即將扣款、「有人欠我」卡片、下次提醒
2. **訂閱**：所有訂閱列表（可搜尋/篩選/排序）
3. **分帳**：朋友別 / 訂閱別雙視角、未收款總額、催款 CTA
4. **統計**：Swift Charts、分類分析、年度儀表板
5. **設定**：通知、主幣別、Face ID、iCloud 同步、匯出、關於

**關鍵畫面清單：**
- `HomeView` — dashboard
- `SubscriptionListView` — 主列表 + 搜尋列
- `SubscriptionDetailView` — 詳情 + 付款歷史 + 分帳狀態
- `SubscriptionEditView` — 新增/編輯表單（支援預設服務庫）
- `ServicePresetPickerView` — 選擇預設服務（Netflix、Spotify…）
- `FriendsListView` — 朋友清單 + 總欠款
- `FriendDetailView` — 某位朋友跨所有訂閱的帳務
- `SharedPlanEditView` — 設定拆帳方式與成員
- `ReminderMessageSheet` — 催款訊息預覽 + Share Sheet
- `StatisticsView` — 圖表
- `SettingsView`
- `OnboardingView` — 首次啟動 3 頁引導

---

## 6. 實作里程碑（假設每週可投入 10-15 小時）

| 週 | 目標 | 交付狀態 |
|---|---|---|
| W1 | Phase 1 — 資料模型、訂閱 CRUD、主列表、詳情、付款週期計算 | 可用的個人訂閱清單 |
| W2 | Phase 1 收尾 — 通知提醒、空狀態、Unit Test；啟動 Phase 2 資料模型 | MVP 完整可交付 |
| W3 | Phase 2 — 分帳完整流程（含預付月份、催款訊息、歷史紀錄） | 旗艦差異化完成 |
| W4 | Phase 3 — 圖表、分類、預設服務庫、搜尋/篩選、試用期、暗黑模式 | 展示用完整度 |
| W5 | Phase 4 — Widget、Siri、iCloud、Face ID、匯出、價格歷史 | 商業級完整度 |

實際上可依你時間壓力彈性在任何 Phase 結束時停手。

---

## 7. 開發細節與陷阱預警

**付款週期計算（容易錯的地方）：**
- 月底 31 號訂閱 → 下個月只有 30 / 28 / 29 天時怎麼處理？用 `Calendar.date(byAdding: .month, value: 1, to:)` 會自動處理到月底，這是正確行為但要寫測試
- 時區：一律用使用者當前時區的 start-of-day，避免跨時區跳日
- 潤年 2/29 年付訂閱 → 同上處理

**分帳預付邏輯：**
- 每月月初（或扣款日當天）跑一次 settle：對每位 prepaidMonthsRemaining > 0 的朋友，扣 1、更新 `lastSettledMonth`
- 用 SwiftData 的 `@Query` + Observation 驅動，不需要背景 task

**通知去重：**
- 訂閱改金額 / 日期 → 移除舊 pending notification，重新排程
- 用 `UNNotificationRequest.identifier = "sub_\(subscription.id)_\(scheduleDate)"` 方便覆寫

**Xcode 專案設定陷阱：**
- Widget 需要新 target（extension），加進 `project.pbxproj` 時要仔細
- iCloud 同步需要在 **Signing & Capabilities** 加 iCloud capability + CloudKit，可能需要你在 Xcode UI 點確認
- 通知權限：第一次請求前要在合適時機（非 App 一啟動就問）

**資料遷移：**
- Phase 間加欄位到 `@Model` → SwiftData 會自動 lightweight migration，但欄位若改型別需寫 `MigrationStage`，盡量只加不改

**隱私：**
- 所有資料本地儲存，不上傳任何 server（除了 iCloud 是使用者自己的 iCloud）
- Info.plist 需要 `NSUserTrackingUsageDescription` 嗎？不用（我們不追蹤）
- 通知權限的 purpose string 要寫清楚

---

## 8. 驗證 / 測試策略

**每個 Phase 結束後：**
```bash
xcodebuild -scheme "Final Project 2" -configuration Debug \
  -destination "platform=iOS Simulator,name=iPhone 17" build
```
然後在 iPhone 17 simulator 跑，手動走完 golden path 與邊界：

- **Phase 1 驗證：** 新增月付訂閱 → 檢查下次扣款日 → 設提醒 1 天前 → 把模擬器時間跳到前一天 → 通知應出現
- **Phase 2 驗證：** 建立 Spotify 家庭方案 4 人平分 → 朋友 A 預付 8 個月 → 跑 9 次月度 settle → A 應進入 unpaid 狀態
- **Phase 3 驗證：** 新增 5 個不同類別訂閱 → 統計頁圓餅圖應正確分布
- **Phase 4 驗證：** Widget 在首頁顯示正確金額、Siri「訂閱花多少」能回答、關 App 後 Face ID 再開需驗證

**Unit Test 覆蓋：**
- `BillingCycleCalculator`（月底 / 潤年 / 自訂天數）
- `ContributionSettler`（預付抵扣邏輯）
- `ReminderScheduler`（排程覆寫、去重）

---

## 9. 關鍵檔案（預計建立）

```
Final Project 2/
├── App/
│   └── Final_Project_2App.swift           # 改：注入 ModelContainer
├── Models/
│   ├── Subscription.swift
│   ├── Friend.swift
│   ├── SharedPlan.swift
│   ├── Contribution.swift
│   ├── PaymentRecord.swift
│   ├── Category.swift
│   └── Enums.swift
├── Services/
│   ├── BillingCycleCalculator.swift
│   ├── ContributionSettler.swift
│   ├── ReminderScheduler.swift
│   ├── ServicePresetLibrary.swift         # 內建服務資料
│   └── ExportService.swift                # Phase 4
├── Views/
│   ├── Home/HomeView.swift
│   ├── Subscriptions/
│   │   ├── SubscriptionListView.swift
│   │   ├── SubscriptionDetailView.swift
│   │   ├── SubscriptionEditView.swift
│   │   └── ServicePresetPickerView.swift
│   ├── Friends/
│   │   ├── FriendsListView.swift
│   │   ├── FriendDetailView.swift
│   │   └── ReminderMessageSheet.swift
│   ├── Statistics/StatisticsView.swift
│   ├── Settings/SettingsView.swift
│   ├── Onboarding/OnboardingView.swift
│   └── Components/                         # 共用元件
├── Widgets/                                # Phase 4 新 target
│   └── SubscriptionWidget.swift
├── Intents/                                # Phase 4
│   └── SubscriptionIntents.swift
├── Resources/
│   ├── Assets.xcassets                     # 加服務 logo / 品牌色
│   └── Localizable.xcstrings
└── Tests/                                  # 新 test target
    ├── BillingCycleTests.swift
    └── ContributionSettlerTests.swift
```

---

## 10. 開始實作的建議順序

1. 我先把 Phase 1 拆成 ~6 個小 commit 做完：模型 → Container 注入 → List → Detail → Edit → 通知
2. 每完成一個 commit，你在 Xcode 跑一次、告訴我體感哪裡怪
3. Phase 1 完成後，我們再討論 Phase 2 分帳的 UI / UX 細節（例如催款訊息的文案風格你想要正式還是可愛）
4. Phase 3 / 4 同理逐步推進

你隨時可以叫停、改方向、或放大 / 縮小某個 Phase。

---

## 11. 實作進度記錄

| Phase | 狀態 | 完成日期 | 備註 |
|---|---|---|---|
| Phase 1 — MVP 核心 | ✅ 完成 | 2026-04-21 | 全部 8 項完成，BUILD SUCCEEDED |
| Phase 2 — 分帳旗艦 | ✅ 完成 | 2026-04-21 | BUILD SUCCEEDED |
| Phase 3 — 視覺化 | ✅ 完成 | 2026-04-22 | 全部 8 項完成，BUILD SUCCEEDED |
| Phase 4 — 進階整合 | ✅ 完成 | 2026-04-25 | 7 項全部完成，BUILD SUCCEEDED |

### Phase 3 交付的檔案清單

**新增 Services**
- `ServicePresetLibrary.swift` — 23 個內建服務 + 7 個預設分類 meta

**新增 Views**
- `Views/Subscriptions/ServicePresetPickerView.swift` — 服務庫選擇 UI（橫向分類快選 + 空分類提示）
- `Views/Settings/CategoryManagementView.swift` — 分類 CRUD（新增/編輯/刪除，含 SF Symbol 選擇器）

**修改 Views**
- `Views/Statistics/StatisticsView.swift` — 月度支出 BarMark、年度趨勢 LineMark+AreaMark、分類 SectorMark、支出排行 Top 5
- `Views/Subscriptions/SubscriptionEditView.swift` — 服務庫快選 + 分類 Picker
- `Views/Subscriptions/SubscriptionDetailView.swift` — 暫停/恢復/取消/重啟狀態操作列
- `Views/Subscriptions/SubscriptionListView.swift` — 篩選 Sheet（狀態 + 分類 + 金額範圍）
- `Views/Settings/SettingsView.swift` — 分類管理入口

**修改 Services**
- `Services/ReminderScheduler.swift` — `scheduleTrialReminder()`，試用到期提醒（最少 2 天）

**修改 App**
- `ContentView.swift` — 首次啟動 seed 7 個預設分類

### Phase 1 交付的檔案清單

**Models（Opus）**
- `Enums.swift`, `Subscription.swift`, `SubscriptionCategory.swift`
- `PaymentRecord.swift`, `PriceHistoryEntry.swift`
- `Friend.swift`, `SharedPlan.swift`, `Contribution.swift`, `SettlementRecord.swift`

**Services**
- `BillingCycleCalculator.swift`（Opus）— 週期計算、月均、所有扣款日
- `ContributionSettler.swift`（Opus）— 分帳結算
- `ReminderScheduler.swift` — 本地通知排程 / 取消 / 去重 / 權限請求

**Views**
- `ContentView.swift` — TabView 五分頁（`Tab` iOS 26 API）+ Onboarding fullScreenCover
- `AppTab.swift` — 分頁 enum
- `Home/` — `HomeView`, `MonthlySummaryCard`, `UpcomingPaymentsSection`, `UpcomingPaymentRow`
- `Subscriptions/` — `SubscriptionListView`, `SubscriptionDetailView`, `SubscriptionEditView`, `DetailRow`, `PaymentHistorySection`
- `Components/` — `BrandIconView`, `SubscriptionRowView`, `ColorExtensions`, `DisplayExtensions`
- `Friends/FriendsListView` — Phase 2 佔位
- `Statistics/StatisticsView` — Phase 3 佔位
- `Settings/SettingsView` — Phase 4 佔位
- `Onboarding/OnboardingView` — 3 頁引導 + 通知授權請求

**Tests（Opus）**
- `BillingCycleCalculatorTests.swift`（13 筆）
- `ContributionSettlerTests.swift`（12 筆）
