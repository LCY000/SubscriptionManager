# 訂閱管家

**把每一分訂閱費都看清楚。**

一款專為訂閱制服務設計的 iOS 個人財務 App。從 Netflix 到 iCloud+，從 Spotify 家庭方案到 Claude Pro，統一管理、精準分帳、真實統計。

> iOS 課程期末專案 · 全 Swift 原生 · 零第三方依賴

---

## 為什麼需要訂閱管家？

你可能有這些困擾：

- 訂閱服務散落各平台，每月到底花了多少？說不清楚
- 試用期到了忘記取消，被自動扣款才發現
- Spotify 家庭方案幾個人共用，誰付了、誰欠錢、誰預付了幾個月——一團混亂
- 朋友主辦的共享方案，根本沒有 App 讓你「只記錄自己那份」

訂閱管家解決的就是這些問題。

---

## 核心功能

### 訂閱總覽
- 集中管理所有訂閱，支援月付、季付、半年、年付、週付、**固定天數間隔**（如每 30 天扣款的 Claude / ChatGPT）
- 自動計算下次扣款日，含月底、閏年邊界正確處理
- 扣款前本地通知提醒，可自訂提前天數
- 內建 23 個常見服務預設（Netflix、Spotify、YouTube Premium 等，含品牌色與 Logo）

### 精準分帳
- 共享方案設定：自訂人數與每人金額（整數平分，餘額由主辦人吸收）
- 朋友名單管理，含 LINE ID 與銀行帳號末5碼
- **預付月份抵扣**：朋友預付 N 個月，系統每月自動扣抵，狀態即時顯示
- 一鍵生成催款訊息，透過 iMessage / LINE 直接傳送

### 「我的份額」精準計算
- 分帳角色系統：一般個人訂閱 / 我主辦分帳 / 朋友主辦我分擔，三種視角各自正確計算
- 首頁、Widget、統計、Siri 全部顯示「我實際付的金額」，不把朋友該付的算進自己支出
- 統計頁可切換「**我的支出**」與「**方案總額**」兩種模式

### 方案分享連結
- 詳情頁一鍵產生深層連結（`subhub://`），透過 LINE / iMessage 分享給朋友
- 主辦人分享時自動帶入完整成員名單與各自分攤金額
- 可指定收件人，對方打開連結後 App 自動高亮並預填對應金額
- 三行純文字格式：邀請語 / 說明 / 連結，在 LINE 完整顯示
- 連結酬載採 zlib 壓縮後 base64，URL 長度約 400 字元，iOS 可完整識別為可點擊連結

### 付款紀錄系統
- 訂閱建立時自動回填歷史付款紀錄；App 切回前景時自動補齊離線期間
- 暫停訂閱期間不產生紀錄，恢復後從恢復日繼續——統計數字真實反映實際支出
- 付款紀錄可手動新增、點擊編輯、左滑刪除
- 統計圖表完全改用真實付款紀錄計算，不再依賴推算

### 視覺化統計
- 月度支出長條圖（近 6 個月）
- 年度趨勢折線圖（近 12 個月）
- 分類支出圓餅圖
- 支出排行 Top 5

### 進階整合
- **Home Screen Widget**：小尺寸本月總支出、中尺寸近 3 筆即將扣款
- **Siri Shortcuts**：「查詢本月訂閱花費」「下一筆扣款是什麼」
- **iCloud 同步**（SwiftData + CloudKit）
- **Face ID / Touch ID 應用程式鎖**
- **CSV 匯出**：含月均換算、下次扣款日、我的份額與角色欄位
- **多幣別支援**（TWD / USD / JPY / EUR），匯率可自訂

---

## 技術架構

全部使用 iOS 原生 API，**零第三方依賴**。

| 層 | 技術 |
|---|---|
| UI | SwiftUI（iOS 26.2） |
| 狀態管理 | `@Observable` macro |
| 資料持久化 | SwiftData（`@Model`） |
| 雲端同步 | CloudKit via SwiftData |
| 通知 | UserNotifications |
| 圖表 | Swift Charts |
| Widget | WidgetKit + TimelineProvider |
| 語音捷徑 | App Intents + AppShortcutsProvider |
| 生物辨識 | LocalAuthentication |
| 在地化 | String Catalogs（`.xcstrings`） |

---

## 開發狀態

| 版本 | 內容 | 狀態 | 完成日期 |
|---|---|---|---|
| Phase 1 | MVP 核心 | ✅ | 2026-04-21 |
| Phase 2 | 旗艦分帳功能 | ✅ | 2026-04-21 |
| Phase 3 | 視覺化統計 | ✅ | 2026-04-22 |
| Phase 4 | 進階 iOS 整合 | ✅ | 2026-04-25 |
| v1.1 | 分帳角色系統 & 深層連結分享 | ✅ | 2026-04-27 |
| v1.2 | 暱稱 + 分享成員列表 + UX 修正 | ✅ | 2026-04-27 |
| v1.3 | PaymentRecord 驅動統計 & 付款紀錄 UI | ✅ | 2026-04-27 |
| v1.4 | 分享 URL zlib 壓縮 & 建議金額 bug 修復 | ✅ | 2026-04-28 |
| v1.5 | 接收方成員列表 UX 改善 | 🔲 待實作 | — |

---

## 建置

```bash
xcodebuild -scheme "Final Project 2" -configuration Debug \
  -destination "platform=iOS Simulator,name=iPhone 17" build
```

互動式開發請直接用 Xcode 開啟 `Final Project 2.xcodeproj`。

**手動設定**：若要讓 `subhub://` 深層連結正常運作，需在 Xcode → Target → Info → URL Types 新增 Scheme `subhub`。

---

## 專案結構

```
Final Project 2/
├── Models/                  # SwiftData @Model
├── Services/                # 週期計算、分帳結算、通知排程、分享編解碼、付款自動生成
├── Views/
│   ├── Home/                # Dashboard
│   ├── Subscriptions/       # 訂閱列表、詳情、編輯、分享、付款紀錄
│   ├── Friends/             # 分帳管理、催款
│   ├── Statistics/          # Swift Charts 統計
│   ├── Settings/            # 設定、分類管理、App 鎖
│   └── Components/          # 共用元件
├── Widgets/                 # WidgetKit Extension
└── Intents/                 # App Intents / Siri

Tests/
├── BillingCycleCalculatorTests.swift       # 13 筆（月底、閏年、自訂天數）
├── ContributionSettlerTests.swift          # 12 筆（預付抵扣邏輯）
├── SubscriptionShareCalculatorTests.swift  # 9 筆（我的份額各角色情境）
└── SubscriptionShareCodecTests.swift       # 6 筆（深層連結 encode/decode，含壓縮與 suggestedShare 保留驗證）
```
