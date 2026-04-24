# Tests

使用 Swift Testing（`@Test` macro，Xcode 16+ 內建，無外部依賴）。

## 目前測試覆蓋

- `BillingCycleCalculatorTests.swift` — 月底 / 閏年 / 週期推進 / 月均 / 年均 / 期間內所有扣款日
- `ContributionSettlerTests.swift` — 預付抵扣 / 寬限期 / 逾期判定 / 批次補結算 / 手動付款 / 增減預付 / 未付總額

## 如何執行（需要先新增 Test Target）

此專案初始化時沒有建立測試 target。新增步驟：

1. Xcode 打開 `Final Project 2.xcodeproj`
2. `File → New → Target…`
3. 選 **iOS → Unit Testing Bundle**
4. Product Name：`Final Project 2Tests`
5. Testing System：**Swift Testing**
6. Target to be Tested：`Final Project 2`
7. 建好後，把本資料夾（`Tests/`）的 `.swift` 檔拖進新建的 test target（或在 target 的 Build Phases → Compile Sources 加入）

完成後執行：

```bash
xcodebuild -scheme "Final Project 2" -configuration Debug \
  -destination "platform=iOS Simulator,name=iPhone 17" test
```

## 為什麼沒自動建 test target

Xcode 專案用 `PBXFileSystemSynchronizedRootGroup`（Xcode 16+ 的新機制），子資料夾會自動同步到 app target。如果把測試檔放在同步資料夾裡，會被編進 app target，造成 `import Testing` 編譯錯誤。所以測試檔必須放在同步資料夾外（本 `Tests/` 資料夾），再透過獨立 test target 編譯。
