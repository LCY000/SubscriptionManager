# 訂閱管家 — 個人訂閱管理 App

iOS 課程期末專案。一款協助使用者集中管理數位訂閱服務的 App，核心差異化功能是 **家庭/共享方案分帳**（處理「誰欠我錢」「預付幾個月還沒抵扣完」這類常見但沒 App 好好解決的情境）。

## 解決的問題

- 訂閱服務散落各平台（Netflix、Spotify、YouTube、iCloud+、外送訂閱…），難以集中掌握
- 常忘記扣款日、試用到期日，導致被意外續約
- 缺少固定支出統計，無法掌握每月/每年訂閱總花費
- **家庭方案分帳混亂**：有人預付幾個月、有人還沒給、要一個個私訊催款
- **分帳金額誤算**：只是 Spotify 家庭方案的成員，App 卻把整筆 390 計入月支出
- **朋友主辦無法只記錄自己份額**：無法以「成員視角」建立他人主辦的共享訂閱

## 主要功能

### Phase 1 — MVP 核心
- 訂閱 CRUD：新增 / 編輯 / 刪除，詳情頁含付款歷史
- 支援月 / 季 / 半年 / 年 / 週 / 自訂天數付款週期
- 自動計算下次扣款日（含月底、閏年邊界正確處理）
- 本地通知扣款提醒，去重設計避免重複通知
- 空狀態畫面、首次啟動 3 頁引導

### Phase 2 — 旗艦分帳功能
- 共享方案設定：人數、平均 / 自訂拆帳金額
- 朋友名單管理（姓名、LINE ID、銀行末 5 碼）
- **預付月份抵扣**：朋友預付 N 個月，系統每月自動扣抵
- 對帳狀態即時顯示：已付 / 預付剩 X 月 / 未付 / 逾期
- 一鍵催款：生成訊息，透過 Share Sheet 傳到 LINE / iMessage
- 分帳歷史紀錄、首頁「有人欠我」總覽卡片

### Phase 3 — 視覺化與體感
- Swift Charts：月度支出長條圖、年度趨勢折線圖、分類圓餅圖
- 內建 23 個常見服務預設庫（Netflix、Spotify、YouTube Premium 等，含品牌色與 Logo）
- 自訂分類系統（影音、音樂、外送、生產力、雲端、遊戲…）
- 試用期管理、暫停 / 恢復 / 取消 / 重啟訂閱狀態
- 訂閱搜尋與多維篩選（狀態、分類、金額範圍）
- 暗黑模式完整支援、Dynamic Type、VoiceOver 無障礙標記

### Phase 4 — 進階 iOS 整合
- **Home Screen Widget**（WidgetKit）：小尺寸顯示本月總支出，中尺寸顯示最近 3 筆即將扣款
- **App Intents / Siri Shortcuts**：「查詢本月訂閱花費」「下一筆扣款是什麼」
- **iCloud 同步**（SwiftData + CloudKit）：設定頁開關，重啟後生效
- **Face ID / Touch ID 應用程式鎖**（LocalAuthentication）：進背景即鎖，返回驗證
- **CSV 匯出**（ShareLink）：含月均換算、下次扣款日、我的份額與角色欄位
- **價格變動歷史**：編輯金額時自動記錄，詳情頁完整歷程
- **多幣別支援**（TWD / USD / JPY / EUR）：首頁與統計統一換算成主幣別，匯率可自訂

### v1.1 — 分帳角色 & 方案分享
- **分帳角色系統**：訂閱可設定為「一般」/「我主辦分帳」/「朋友主辦我分擔」三種角色
  - 朋友主辦時可自填每次應付金額（`myShareOverride`），不再只能從主辦人視角記錄
- **「我的份額」精準計算**（`SubscriptionShareCalculator`）：
  - 首頁、Widget、Siri 的月支出改為「我實際付的金額」而非方案總額
  - 統計頁新增 **我的支出 / 方案總額** 切換（Segmented Picker）
  - 訂閱 Row 顯示「我每月付 X」，分帳時副標顯示方案總額
- **訂閱方案深層連結分享**（URL Scheme `subhub://`）：
  - 詳情頁工具列 ShareLink 按鈕，透過 LINE / iMessage 分享
  - 收到連結後開啟 **ImportSubscriptionView**，預覽方案資訊並可調整份額後匯入
  - 格式：`subhub://import?v=1&data=<base64url-json>`，版本化設計方便升級

## 技術架構

全部使用 iOS 原生 API，**零第三方依賴**。

| 層 | 技術 |
|---|---|
| UI | SwiftUI（iOS 26.2 target） |
| 狀態 | `@Observable` macro（Swift 5.9+） |
| 資料 | SwiftData（`@Model`） |
| 同步 | CloudKit via SwiftData |
| 通知 | UserNotifications |
| 圖表 | Swift Charts |
| Widget | WidgetKit + TimelineProvider |
| 捷徑 | App Intents + AppShortcutsProvider |
| 安全 | LocalAuthentication |
| 在地化 | String Catalogs（`.xcstrings`） |

## 專案設定

- **Bundle ID:** `work.Final-Project-2`
- **iOS Deployment Target:** 26.2
- **Swift:** 5.0（啟用 `SWIFT_APPROACHABLE_CONCURRENCY`、`SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY`）
- **Code Signing:** Automatic，Team `X2AWFYCC2H`
- **URL Scheme:** `subhub://`（需在 Xcode → Target → Info → URL Types 手動登錄）

## 建置與執行

```bash
# 模擬器建置
xcodebuild -scheme "Final Project 2" -configuration Debug \
  -destination "platform=iOS Simulator,name=iPhone 17" build

# 執行單元測試（需先在 Xcode 建立 Unit Testing Bundle target，見 Tests/README.md）
xcodebuild -scheme "Final Project 2" -configuration Debug \
  -destination "platform=iOS Simulator,name=iPhone 17" test
```

互動式開發請直接用 Xcode 打開 `Final Project 2.xcodeproj`。

## 專案結構

```
Final Project 2/
├── Final_Project_2App.swift     # @main，ModelContainer 注入，Face ID 鎖，深層連結路由
├── ContentView.swift            # TabView 五分頁 + Onboarding
├── Models/
│   ├── Subscription.swift              # @Model，含 isOrganizer / myShareOverride（v1.1）
│   ├── SubscriptionCategory.swift
│   ├── Friend.swift / SharedPlan.swift / Contribution.swift
│   ├── PaymentRecord.swift / PriceHistoryEntry.swift / SettlementRecord.swift
│   ├── SharedSubscriptionPayload.swift # 跨 App 傳輸 DTO（v1.1）
│   └── Enums.swift
├── Services/
│   ├── BillingCycleCalculator.swift        # 週期計算（含月底/閏年）
│   ├── ContributionSettler.swift           # 分帳結算邏輯
│   ├── SubscriptionShareCalculator.swift   # 我的份額計算（v1.1）
│   ├── SubscriptionShareEncoder.swift      # 深層連結編碼（v1.1）
│   ├── SubscriptionShareDecoder.swift      # 深層連結解碼（v1.1）
│   ├── ReminderScheduler.swift             # 本地通知排程
│   ├── ServicePresetLibrary.swift          # 23 個內建服務 + 7 個預設分類
│   ├── CurrencyConverter.swift             # 多幣別換算
│   ├── ExportService.swift                 # CSV 匯出（含我的份額與角色欄位）
│   └── WidgetRefresher.swift               # Widget 資料同步
├── Views/
│   ├── Home/                    # 首頁 Dashboard（月支出改用我的份額）
│   ├── Subscriptions/           # 訂閱列表、詳情（分角色徽章）、編輯（分帳角色 Picker）
│   │   └── ImportSubscriptionView.swift    # 深層連結匯入畫面（v1.1）
│   ├── Friends/                 # 分帳、朋友管理、催款
│   ├── Statistics/              # Swift Charts 統計頁（我的支出/方案總額切換）
│   ├── Settings/                # 設定頁、分類管理、App 鎖畫面
│   ├── Onboarding/              # 首次啟動引導
│   └── Components/              # 共用元件
├── Intents/
│   └── SubscriptionIntents.swift    # App Intents + Siri Shortcuts（我的份額）
├── Widgets/
│   └── SubscriptionWidget.swift     # Widget Extension（需獨立 target）
└── Assets.xcassets              # 服務 Logo + 品牌色

Tests/
├── BillingCycleCalculatorTests.swift       # 13 筆測試（月底、閏年、自訂天數）
├── ContributionSettlerTests.swift          # 12 筆測試（預付抵扣邏輯）
├── SubscriptionShareCalculatorTests.swift  # 9 筆測試（我的份額各角色情境）
└── SubscriptionShareCodecTests.swift       # 5 筆測試（深層連結 encode/decode）
```

## 開發狀態

| Phase | 狀態 | 完成日期 |
|---|---|---|
| Phase 1 — MVP 核心 | ✅ 完成 | 2026-04-21 |
| Phase 2 — 分帳旗艦 | ✅ 完成 | 2026-04-21 |
| Phase 3 — 視覺化 | ✅ 完成 | 2026-04-22 |
| Phase 4 — 進階整合 | ✅ 完成 | 2026-04-25 |
| v1.1 — 分帳角色 & 方案分享 | ✅ 完成 | 2026-04-27 |
