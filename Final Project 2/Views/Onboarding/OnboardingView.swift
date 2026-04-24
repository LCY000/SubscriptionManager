import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "creditcard.and.123",
            imageColor: .blue,
            title: "訂閱一覽",
            description: "將 Netflix、Spotify、iCloud+ 等所有訂閱集中管理，不再錯過任何一筆支出。"
        ),
        OnboardingPage(
            systemImage: "bell.badge.fill",
            imageColor: .orange,
            title: "扣款不漏接",
            description: "在扣款前 1 天（或自訂天數）收到提醒，試用期到期也不會被悄悄扣款。"
        ),
        OnboardingPage(
            systemImage: "person.2.fill",
            imageColor: .green,
            title: "家庭方案分帳",
            description: "記錄每位朋友的預付月份，一鍵產生催款訊息直接分享到 LINE 或 iMessage。"
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)

            VStack(spacing: 12) {
                if currentPage == pages.count - 1 {
                    Button("開始使用", action: requestNotificationAndFinish)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 14))
                } else {
                    Button("下一步", action: nextPage)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 14))

                    Button("略過", action: finish)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func nextPage() {
        withAnimation(.easeInOut) { currentPage += 1 }
    }

    private func requestNotificationAndFinish() {
        Task {
            _ = await ReminderScheduler.requestPermission()
            await MainActor.run { finish() }
        }
    }

    private func finish() {
        hasCompletedOnboarding = true
    }
}

private struct OnboardingPage {
    let systemImage: String
    let imageColor: Color
    let title: String
    let description: String
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: page.systemImage)
                .font(.system(size: 80))
                .foregroundStyle(page.imageColor)
                .symbolEffect(.pulse)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    OnboardingView()
}
