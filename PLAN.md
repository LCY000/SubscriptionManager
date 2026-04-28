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
| 擴充 — 三大痛點修正（v1.1） | ✅ 完成 | 2026-04-26 | 我的份額模型、朋友主辦流程、深層連結分享，BUILD SUCCEEDED |
| Phase E — 暱稱 + 分享成員列表（v1.2） | ✅ 完成 | 2026-04-27 | 五項 UX 修正 + 分享成員列表 + 三行訊息格式，BUILD SUCCEEDED |
| Phase F — PaymentRecord 驅動統計（v1.3） | ✅ 完成 | 2026-04-27 | 付款紀錄自動生成、可編輯歷史、統計改用真實紀錄，BUILD SUCCEEDED |
| Phase G — 分享 URL 修復（v1.4） | ✅ 完成 | 2026-04-28 | zlib 壓縮縮短 URL、suggestedShare 優先順序 bug、Codec 測試 6 筆，BUILD SUCCEEDED |
| Phase H — 接收方成員列表 UX 改善（v1.5） | 🔲 待實作 | — | recipientName 欄位、（我）標示、加入好友、成員金額可編輯 |

### 擴充修正 — 2026-04-26

**痛點修正範圍**

- 痛點 1：**朋友主辦的訂閱可只記錄自己份額** — `Subscription` 加 `isOrganizer: Bool = true` 與 `myShareOverride: Decimal?`（lightweight migration）
- 痛點 2：**深層連結分享方案** — `subhub://import?v=1&data=<base64-json>`，朋友點連結直接喚起匯入流程
- 痛點 3：**月度/統計顯示淨額** — 全部金額計算改用 `myMonthlyShare`，不再把朋友該分擔的部分算進「我的支出」

**新增檔案**

- `Services/SubscriptionShareCalculator.swift` — `myAmount` / `myMonthlyShare` / `myYearlyShare`
- `Models/SharedSubscriptionPayload.swift` — 跨 App 傳輸 DTO（`Codable struct`，非 SwiftData）
- `Services/SubscriptionShareEncoder.swift` — Subscription → URL，含 base64URL 編碼
- `Services/SubscriptionShareDecoder.swift` — URL → Payload，含版本驗證
- `Views/Subscriptions/ImportSubscriptionView.swift` — 接收方匯入預覽 + `ImportRouter @Observable`
- `Tests/SubscriptionShareCalculatorTests.swift` — 9 個測試，覆蓋一般 / 朋友主辦 / 我主辦 / 季付 / override 邊界
- `Tests/SubscriptionShareCodecTests.swift` — 5 個測試，覆蓋 round-trip / URL 結構 / 版本驗證 / 年付

**修改檔案**

- `Models/Subscription.swift` — 加 `isOrganizer`、`myShareOverride`
- `Views/Home/HomeView.swift` — `monthlyTotal` 改用 myShare
- `Views/Statistics/StatisticsView.swift` — 加 `viewMode` segmented picker（我的支出 / 方案總額），全部圖表跟著切換
- `Services/WidgetRefresher.swift` — Widget 顯示我的份額
- `Intents/SubscriptionIntents.swift` — Siri 回答我的份額
- `Services/ExportService.swift` — CSV 加「我的份額」「角色」兩欄
- `Views/Subscriptions/SubscriptionEditView.swift` — 加 `ShareMode` picker（一般 / 我主辦分帳 / 朋友主辦我分擔）
- `Views/Subscriptions/SubscriptionDetailView.swift` — 加角色徽章、`我每次付` row、ShareLink toolbar
- `Views/Subscriptions/SharedPlanEditView.swift` — 朋友主辦時 guard 進入
- `Views/Components/SubscriptionRowView.swift` — 顯示我的份額為主，副標小字方案全額
- `Views/Home/UpcomingPaymentRow.swift` — 同上
- `Final Project 2/Final_Project_2App.swift` — `.onOpenURL` + ImportRouter sheet/alert

**手動 Xcode 設定（需使用者操作）**

要讓 `subhub://` URL 在 LINE / iMessage 點擊後喚起 App：
1. Xcode → `Final Project 2` target → `Info` tab → `URL Types` 點 `+`
2. URL Schemes 填 `subhub`
3. Identifier 填 `work.Final-Project-2.share`

未設定時：分享連結仍可產生（`SubscriptionShareEncoder.encode`），但點擊不會自動匯入，需使用者手動處理。

**Test target 提醒**：新增的 `SubscriptionShareCalculatorTests` 與 `SubscriptionShareCodecTests` 需在 Tests/ 拖進 test target 才會跑（同既有 `BillingCycleCalculatorTests`）。


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

---

## Phase E：暱稱 + 分享成員列表 + 訊息格式化（v1.2）

> 狀態：✅ 完成，2026-04-27

### Context

Phase D 實作了深層連結分享（`subhub://`），但有兩個問題：
1. 分享出去的訊息格式差（URL 在前、說明在後，使用者看不懂如何操作）
2. Payload 缺少「主辦人是誰」和「其他成員分擔多少」的資訊，收件方完全不知道方案全貌

目標：
1. **設定暱稱** — 顯示在分享訊息與 ImportSubscriptionView 主辦人欄
2. **主辦人分享時帶完整成員名單**（名字 + 各自金額）打包進 payload
3. **分享前可選指定收件人** → App 自動高亮該成員 + 預填金額（可選，不強制）
4. **分享訊息改為三行純文字格式**，URL 在最後一行

### 分享訊息目標格式

```
陳大明 邀請你加入「Spotify 家庭」方案！
點擊連結，用「訂閱管家」一鍵匯入方案
subhub://import?v=2&data=eyJ...
```

`\n` 在 LINE / iMessage / 複製貼上都保留為真實換行。`item` 從 `URL` 改為 `String`，subhub:// URL 在已安裝 App 的裝置仍可點擊觸發。

### 資料流設計

```
分享方（主辦人，暱稱「陳大明」）
  PreShareSheet：
    成員列表（唯讀）：陳大明(你) 130 / 林沛妤 130 / 王小明 130
    指定收件人 Picker：不指定 / 林沛妤 / 王小明
    → 選林沛妤 → 分配金額自動填 130

  Encoder payload：
    organizerName = "陳大明"
    members = [{陳大明, 130, isOrganizer:true}, {林沛妤, 130}, {王小明, 130}]
    recipientName = "林沛妤"
    suggestedShare = 130  ← 無 members 資料時的 fallback

接收方（林沛妤）
  ImportSubscriptionView：
    主辦人：陳大明
    共享成員：陳大明 NT$130 / ▶林沛妤 NT$130（反白・預填）/ 王小明 NT$130
    我的角色：[✓] 朋友主辦
    我每次付：130（from matched member）
```

### 關鍵設計決策

- **版本號升至 v=2**：`SharedSubscriptionPayload.currentVersion = 2`；decoder 檢查 `version <= currentVersion`，收到 v=1 舊連結仍可正常解碼（新欄位 Optional，舊連結中不存在即為 nil）
- **非主辦人分享**：`isOrganizer == false` → `organizerName/members = nil`，沿用 v1.1
- **暱稱未填**：不傳 organizerName，成員列表中主辦人那行也不加（避免空名）
- **`Contribution.amountPerMonth` 實際是 per-cycle**：與 `subscription.amount` 同單位，不需換算

### 修改檔案清單

| 檔案 | 動作 | 說明 |
|---|---|---|
| `Models/SharedSubscriptionPayload.swift` | 改 | 新增 `SharedMemberInfo` struct；payload 加 `organizerName`、`members`、`recipientName` |
| `Views/Settings/SettingsView.swift` | 改 | 最頂部新增「個人」Section，含「我的暱稱」TextField（`@AppStorage("userNickname")`） |
| `Services/SubscriptionShareEncoder.swift` | 改 | 新增 `recipientName` 參數；讀 nickname；isOrganizer 時從 sharedPlan 建 members 列表 |
| `Views/Subscriptions/SubscriptionDetailView.swift` | 改 | PreShareSheet：成員唯讀列表、指定收件人 Picker、`buildShareText(url:)` → `ShareLink(item: String)` |
| `Views/Subscriptions/ImportSubscriptionView.swift` | 改 | 加「主辦人」列；新增「共享成員」Section（recipientName 反白）；init 優先 matched member 金額 |

### 實作細節

**SharedSubscriptionPayload 新增：**
```swift
struct SharedMemberInfo: Codable, Hashable {
    var name: String
    var amountPerCycle: Decimal
    var isOrganizer: Bool
}
// payload 加，同時 currentVersion 改為 2：
static let currentVersion = 2
var organizerName: String?
var members: [SharedMemberInfo]?
var recipientName: String?
```

**Encoder 建 members 邏輯（isOrganizer && sharedPlan != nil 時）：**
```swift
var list: [SharedMemberInfo] = []
if let nick = nickname, !nick.isEmpty {
    list.append(.init(name: nick, amountPerCycle: myAmt, isOrganizer: true))
}
for c in plan.contributions {
    if let n = c.friend?.name {
        list.append(.init(name: n, amountPerCycle: c.amountPerMonth, isOrganizer: false))
    }
}
members = list.isEmpty ? nil : list
```

**PreShareSheet 成員唯讀列表（顯示在 Picker 上方）：**
```swift
let nickname = UserDefaults.standard.string(forKey: "userNickname") ?? ""
let contributions = subscription.sharedPlan?.contributions ?? []

// 主辦人自己那行（只在暱稱有填時顯示）
if !nickname.isEmpty {
    HStack {
        Text(nickname)
        Text("（你）").foregroundStyle(.secondary)
        Spacer()
        Text(defaultSuggestedShare.formatted(.currency(code: subscription.currency)))
    }
}
// 朋友各行
ForEach(contributions, id: \.id) { c in
    if let name = c.friend?.name {
        HStack {
            Text(name)
            Spacer()
            Text(c.amountPerMonth.formatted(.currency(code: subscription.currency)))
        }
    }
}
```

**PreShareSheet 收件人 Picker（取金額從 sharedPlan.contributions，勿用 friend.contributions）：**
```swift
@State private var selectedRecipient: String? = nil

Picker("這個連結分享給", selection: $selectedRecipient) {
    Text("不指定").tag(String?.none)
    ForEach(contributions.compactMap { $0.friend }, id: \.name) { f in
        Text(f.name).tag(Optional(f.name))
    }
}
.onChange(of: selectedRecipient) { _, name in
    if let name,
       let c = contributions.first(where: { $0.friend?.name == name }) {
        suggestedShareString = "\(c.amountPerMonth)"
    } else {
        // 切回「不指定」時還原主辦人份額
        suggestedShareString = "\(defaultSuggestedShare)"
    }
}
```

**buildShareText（PreShareSheet 內）：**
```swift
private func buildShareText(url: URL) -> String {
    let nickname = UserDefaults.standard.string(forKey: "userNickname") ?? ""
    let invite = nickname.isEmpty ? "有人" : nickname
    return "\(invite) 邀請你加入「\(subscription.name)」方案！\n點擊連結，用「訂閱管家」一鍵匯入方案\n\(url.absoluteString)"
}
// ShareLink 改為：
ShareLink(item: buildShareText(url: url), subject: Text("訂閱方案邀請")) { ... }
```

**ImportSubscriptionView init 金額優先順序：**
1. `payload.recipientName` 對應的 `member.amountPerCycle`
2. `payload.suggestedShare`
3. `payload.amount`（全額）

**金額輸入欄 footer 說明文字（動態，依情境切換）：**
```swift
var amountFooter: String {
    if payload.recipientName != nil {
        // 有指定收件人（不論是否有主辦人名字）
        if let org = payload.organizerName, !org.isEmpty {
            return "由 \(org) 分配的金額，可自行調整"
        } else {
            return "由分享者分配的金額，可自行調整"
        }
    } else if payload.suggestedShare != nil {
        return "分享者提供的參考金額，可自行調整"
    } else {
        return "請填入你實際分擔的金額"
    }
}
```
TextField 維持可編輯，footer 只說明金額來源，讓使用者知道這是分配值而非系統推算。

**ImportSubscriptionView 成員列表高亮：**
```swift
ForEach(members, id: \.name) { member in
    HStack {
        if member.name == payload.recipientName {
            Image(systemName: "person.fill.checkmark").foregroundStyle(.blue).font(.caption)
        }
        Text(member.name)
            .fontWeight(member.name == payload.recipientName ? .semibold : .regular)
        Spacer()
        Text(member.amountPerCycle.formatted(.currency(code: payload.currency)))
            .foregroundStyle(member.name == payload.recipientName ? .primary : .secondary)
    }
}
```

### 潛在陷阱

1. **`Friend.contributions` 跨 Plan**：取金額一定從 `subscription.sharedPlan!.contributions` 找，不走 `friend.contributions`
2. **暱稱未填**：organizer 那行不加進 members，避免空名字出現
3. **recipientName 不在 members**：ImportSubscriptionView 不做高亮，用 `suggestedShare` 預填，安全退化
4. **URL 長度**：6 成員 × ~60 chars → base64 ~350 chars，遠低於 4096 bytes 上限
5. **非主辦人分享**：`isOrganizer == false` → members/organizerName = nil，不影響

### 驗證 golden path

| # | 操作 | 預期 |
|---|---|---|
| 1 | 設定頁填暱稱「陳大明」 | UserDefaults 存入 |
| 2 | Spotify 390，我主辦，加林沛妤 130、王小明 130 | 主辦人份額 130 |
| 3 | 詳情頁點分享 → PreShareSheet | 成員列表三人；Picker 有「不指定/林沛妤/王小明」 |
| 4 | 選「林沛妤」→ 建議金額自動填 130 → 點分享 | 訊息三行，URL 在最後 |
| 5 | 另一台點連結 | ImportSubscriptionView 顯示主辦人「陳大明」、三人列表、「林沛妤」反白 |
| 6 | 按加入 | 建立「朋友主辦，myShareOverride=130」訂閱 |
| 7 | 分享給「不指定」→ 收件方 | 成員列表三人，無反白 |
| 8 | 暱稱留空再分享 | ImportSubscriptionView 不顯示主辦人列 |
| 9 | 查看 LINE 收到的文字 | 三行格式，非純 URL |
| 10 | 暱稱「陳大明」分享 | 第一行「陳大明 邀請你加入…」 |
| 11 | PreShareSheet 選「林沛妤」後切回「不指定」 | 建議金額還原為主辦人份額（130），不卡在 130 |
| 12 | 有 recipientName 但 organizerName 空（暱稱未填）時收到連結 | footer 顯示「由分享者分配的金額，可自行調整」（不出現空名） |

---

## Phase F：PaymentRecord 驅動統計（v1.3）

> 狀態：✅ 完成，2026-04-27

### Context

Phase E 以前，統計系統完全靠 `BillingCycleCalculator` 推算付款日期，`PaymentRecord` model 雖存在但從未寫入，導致三個問題：

1. **統計不準確**：暫停/取消期間仍被計入；使用者無法刪除多記的那筆
2. **暫停語意不一致**：pause / cancel 在計算上完全相同，歷史紀錄也沒有差別
3. **30天固定週期 UX 不清楚**：Claude / ChatGPT 等按固定30天扣款，「自訂天數」label 不直觀

### 架構決策

- 訂閱**建立時**立即從 `firstPaymentDate` 回填所有過去 `PaymentRecord`（系統在開發中，無舊版本相容需求）
- 暫停 = 暫停自動產生紀錄；取消 = 停止追蹤。每次狀態變更（pause / resume / cancel / reactivate）都把 `lastAutoGeneratedDate = Date()` 凍結到今天，避免恢復後回填中間空白期
- `PaymentRecord` 同時存 `amount`（我的份額快照）和 `planAmount`（方案全額快照），讓統計在「我的支出」和「方案總額」兩種模式下都能用真實紀錄

### 修改檔案清單

| 檔案 | 改動 |
|---|---|
| `Models/PaymentRecord.swift` | 加 `planAmount: Decimal = Decimal.zero` 欄位與 init 參數 |
| `Models/Subscription.swift` | 加 `lastAutoGeneratedDate: Date?`（SwiftData lightweight migration） |
| `Services/PaymentAutoGenerator.swift` | **新建**：`run(for:in:)` / `runAll(for:in:)` 靜態方法 |
| `Views/Subscriptions/SubscriptionEditView.swift` | 新增訂閱時呼叫 `run()`；「自訂天數」改名「固定天數間隔」；週期 Section 加 footer 說明 |
| `Views/Subscriptions/ImportSubscriptionView.swift` | 匯入後呼叫 `run()` |
| `ContentView.swift` | 加 `@Environment(\.scenePhase)`；App 前景時呼叫 `runAll()` |
| `Views/Subscriptions/SubscriptionDetailView.swift` | `setStatus()` 每次狀態變更都凍結 `lastAutoGeneratedDate`；已暫停狀態加說明文字；`paymentHistoryCard` 永遠顯示，改傳 `subscription` |
| `Views/Subscriptions/PaymentHistorySection.swift` | 改傳 `subscription`；移除 10 筆限制；加 swipe-to-delete；tap 開編輯；header 加「＋」新增按鈕；空狀態文字 |
| `Views/Subscriptions/PaymentRecordEditView.swift` | **新建**：新增/編輯 `PaymentRecord` 的表單（日期、金額、備註） |
| `Views/Statistics/StatisticsView.swift` | `monthlyChartData` / `yearlyTrendData` 改用 `sub.paymentRecords` 迴圈：myShare 取 `record.amount`，planTotal 取 `record.planAmount` |

### PaymentAutoGenerator 邏輯

```swift
static func run(for subscription: Subscription, in context: ModelContext) {
    guard subscription.status == .active || subscription.status == .trial else { return }

    let today = Calendar.current.startOfDay(for: Date())
    let from: Date
    let exclusiveFrom: Bool

    if let last = subscription.lastAutoGeneratedDate {
        from = Calendar.current.startOfDay(for: last)
        exclusiveFrom = true   // 上次已產生到 from 這天，從之後開始
    } else {
        from = Calendar.current.startOfDay(for: subscription.firstPaymentDate)
        exclusiveFrom = false  // 首次，包含 firstPaymentDate
    }

    let allDates = calculator.paymentDates(firstPaymentDate:billingCycle:through: today)
    let newDates = allDates.filter { exclusiveFrom ? $0 > from : $0 >= from }

    for date in newDates {
        context.insert(PaymentRecord(paidDate: date, amount: myAmt, planAmount: sub.amount, ...))
    }
    subscription.lastAutoGeneratedDate = today
}
```

### setStatus 凍結邏輯

```swift
private func setStatus(_ newStatus: SubscriptionStatus) {
    subscription.status = newStatus
    subscription.lastAutoGeneratedDate = Date()  // 無論往哪個方向都凍結
    Task { await ReminderScheduler.schedule(for: subscription) }
}
```

**為什麼每個方向都要更新**：若只在暫停/取消時更新，恢復時 `lastAutoGeneratedDate` 停在暫停那天，下次 `runAll()` 會把整段暫停期補上（錯誤）。

### 驗證清單

| # | 操作 | 預期 |
|---|---|---|
| 1 | 新增月付訂閱，firstPaymentDate = 3個月前 | 詳情頁立即看到 3 筆 PaymentRecord |
| 2 | 背景切前景（模擬隔天） | 新增1筆，不重複 |
| 3 | 暫停（5/1）→ 等兩個月 → 恢復（7/1） | 5、6月無 PaymentRecord；7月起正常產生 |
| 4 | 詳情頁顯示「已暫停：此段期間費用不計入統計」 | 暫停狀態下出現說明文字 |
| 5 | 取消 → 重新啟用 | 取消期間無紀錄，重啟後下個週期再產生 |
| 6 | 左滑刪除一筆 PaymentRecord | 統計頁那個月金額減少 |
| 7 | 點一筆 PaymentRecord → 編輯金額 | 統計頁即時更新 |
| 8 | PaymentHistorySection 點「＋」手動新增 | 統計即時更新 |
| 9 | 統計切換 myShare / planTotal | myShare 用 record.amount；planTotal 用 record.planAmount |
| 10 | 設「固定天數間隔」30 天 | footer 顯示「固定天數間隔扣款（如：Claude、ChatGPT 每30天）」 |

## Phase G：分享 URL 修復（v1.4）

### 問題

1. **URL 太長**：JSON → base64 不壓縮，3 成員 YouTube Premium 約 800+ 字元。iOS 的 NSDataDetector 只把前半段識別為可點擊連結，後半段變純文字。
2. **手動修改建議金額被覆蓋（bug）**：`SubscriptionShareEncoder.encode(_ subscription:)` 在有指定 `recipientName` 時一律用 DB 的 `c.amountPerMonth`，完全忽略傳入的 `suggestedShare` 參數。接收端 `ImportSubscriptionView.init` 也有同樣問題（recipientName member 優先於 suggestedShare）。

### 修復內容（✅ 2026-04-28 完成）

#### URL 壓縮

- `SharedSubscriptionPayload.currentVersion` 2 → 3（記錄格式改變）
- `SubscriptionShareEncoder.encode(_ payload:)`：JSON 序列化後用 `NSData.compressed(using: .zlib)` 壓縮，再 base64
- `SubscriptionShareDecoder.decode(_ url:)`：base64 解碼後直接 `NSData.decompressed(using: .zlib)` 解壓縮
- 效果：URL 長度約 800+ → ~400 字元，NSDataDetector 可完整識別

#### 手動金額 bug 修復

- `SubscriptionShareEncoder`：`suggestedShare` 傳入值永遠優先，僅當 `suggestedShare == nil` 時才從 DB 取 `c.amountPerMonth`
- `ImportSubscriptionView.init`：initialShare 優先順序改為 `suggestedShare` → `recipientName` matched member → `payload.amount`

#### 測試

- `SubscriptionShareCodecTests`：修現存 bug（urlStructure 版本號 `"1"` → `"3"`）；新增 `suggestedSharePreservedWithMembers` 驗證 round-trip

### 修改檔案

| 檔案 | 改動 |
|---|---|
| `Models/SharedSubscriptionPayload.swift` | currentVersion 2 → 3 |
| `Services/SubscriptionShareEncoder.swift` | 壓縮 + shareAmount 優先順序修正 |
| `Services/SubscriptionShareDecoder.swift` | 解壓縮 |
| `Views/Subscriptions/ImportSubscriptionView.swift` | init 優先順序修正 |
| `Tests/SubscriptionShareCodecTests.swift` | 修 bug + 新增測試 |

## Phase H：接收方成員列表 UX 改善（v1.5，待實作）

### 問題

1. **無法知道哪個成員是自己**：接收方匯入後，成員列表沒有標示「（我）」
2. **無法將成員加到好友列表**：接收方看到方案成員，但分帳 Tab 是空的，無法一鍵新增。加入後應可在分帳 Tab 自行編輯付款資訊、備註
3. **成員金額靜態 + 我的金額不同步**：
   - importedMembersJSON 匯入後就固定，無法後續修改
   - 在 SubscriptionEditView 改了 myShareOverride，成員列表仍顯示舊值

### 根因

- `recipientName`（主辦人分配給我的名字）沒有存到 Subscription，導致無法識別「我是誰」
- importedMembersJSON 完全唯讀，無編輯 UI

### 修改檔案（3 個，不新增檔案）

| 檔案 | 改動 |
|---|---|
| `Models/Subscription.swift` | 加 `var recipientName: String?`（SwiftData lightweight migration） |
| `Views/Subscriptions/ImportSubscriptionView.swift` | `importNow()` 傳入 `recipientName: roleIsMember ? payload.recipientName : nil` |
| `Views/Subscriptions/SubscriptionDetailView.swift` | 多處改動（見下） |

### SubscriptionDetailView 改動詳細

#### 新增 state 與 query

```swift
@Query private var allFriends: [Friend]
@State private var showingMembersEditSheet = false
@State private var addFriendToastMessage: String? = nil
@State private var memberToLink: String? = nil
```

#### body 新增 sheet + toast

```swift
.sheet(isPresented: $showingMembersEditSheet) {
    ImportedMembersEditSheet(subscription: subscription)
}
.sheet(isPresented: Binding(get: { memberToLink != nil }, set: { if !$0 { memberToLink = nil } })) {
    if let name = memberToLink {
        FriendPickerSheet(friends: allFriends) { selectedFriend in
            renameMember(from: name, to: selectedFriend.name)
        }
    }
}
.overlay(alignment: .bottom) {
    if let msg = addFriendToastMessage {
        Text(msg)
            .font(.subheadline).foregroundStyle(.white)
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(.black.opacity(0.75)).clipShape(.capsule)
            .padding(.bottom, 24)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onAppear {
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    withAnimation { addFriendToastMessage = nil }
                }
            }
    }
}
.animation(.easeInOut(duration: 0.25), value: addFriendToastMessage)
```

#### sharedPlanCard 非主辦人區塊改動

- Header 加「編輯」按鈕 → `showingMembersEditSheet = true`
- ForEach 成員列：
  - `let isMe = member.name == subscription.recipientName`
  - `let displayAmount = isMe ? (subscription.myShareOverride ?? member.amountPerCycle) : member.amountPerCycle`
  - 顯示「（我）」Text（blue, caption），`isMe` 成員 name 加 semibold
  - `.contextMenu`：非我的成員顯示「建立新朋友」＋（`allFriends` 不空時）「連結現有朋友」

#### 兩個 helper 方法

```swift
private func addToFriendList(name: String) {
    let descriptor = FetchDescriptor<Friend>(predicate: #Predicate { $0.name == name })
    let exists = (try? modelContext.fetch(descriptor))?.isEmpty == false
    if !exists {
        modelContext.insert(Friend(name: name))
        withAnimation { addFriendToastMessage = "已將「\(name)」加入好友列表" }
    } else {
        withAnimation { addFriendToastMessage = "「\(name)」已在好友列表中" }
    }
}

private func renameMember(from oldName: String, to newName: String) {
    guard let json = subscription.importedMembersJSON,
          let data = json.data(using: .utf8),
          var members = try? JSONDecoder().decode([SharedMemberInfo].self, from: data)
    else { return }
    if let i = members.firstIndex(where: { $0.name == oldName }) {
        members[i] = SharedMemberInfo(name: newName,
                                      amountPerCycle: members[i].amountPerCycle,
                                      isOrganizer: members[i].isOrganizer)
    }
    if let updated = try? JSONEncoder().encode(members),
       let str = String(data: updated, encoding: .utf8) {
        subscription.importedMembersJSON = str
    }
    memberToLink = nil
    withAnimation { addFriendToastMessage = "已連結「\(newName)」" }
}
```

#### 兩個 private struct（檔案末尾）

**`FriendPickerSheet`**：接收 `[Friend]` 列表和 `onSelect` closure，讓使用者選擇要連結的現有朋友。

**`ImportedMembersEditSheet`**：在 `init` 時解碼 importedMembersJSON，建立 `[String: String]` 的 amountStrings 字典（「我」那列從 myShareOverride 取初始值）；`save()` 時同步 myShareOverride 與 importedMembersJSON。名稱唯讀，只開放金額修改。

### 設計決策

- **名稱唯讀（EditSheet）**：編輯 sheet 只開放金額，名稱靠 context menu →「連結現有朋友」更新
- **「連結現有朋友」效果**：把 importedMembersJSON 裡那個成員的名字改成選定 Friend 的名字，讓識別符一致
- **加入好友後可自行編輯**：建立的 Friend 物件出現在分帳 Tab，可在那裡正常編輯付款資訊、備註
