import SwiftUI
import LocalAuthentication

struct AppLockView: View {
    var onUnlock: () -> Void
    @State private var errorMessage: String?
    @State private var isAuthenticating = false

    var body: some View {
        ZStack {
            // 背景漸層
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // App icon 區塊
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.blue.gradient)
                            .frame(width: 96, height: 96)
                            .shadow(color: .blue.opacity(0.3), radius: 16, y: 8)

                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 6) {
                        Text("訂閱管家")
                            .font(.title.bold())
                        Text("驗證身份以繼續")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // 解鎖按鈕區
                VStack(spacing: 16) {
                    if let err = errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)
                            Text(err)
                                .foregroundStyle(.red)
                        }
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .transition(.opacity)
                    }

                    Button(action: authenticate) {
                        HStack(spacing: 10) {
                            Image(systemName: biometricIcon)
                            Text(biometricLabel)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 16))
                    }
                    .disabled(isAuthenticating)
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 56)
            }
        }
        .onAppear(perform: authenticate)
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }

    // MARK: - 依裝置能力決定圖示和文字

    private var biometricIcon: String {
        let ctx = LAContext()
        var err: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) else {
            return "lock.open.fill"
        }
        return ctx.biometryType == .faceID ? "faceid" : "touchid"
    }

    private var biometricLabel: String {
        let ctx = LAContext()
        var err: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) else {
            return "輸入密碼解鎖"
        }
        return ctx.biometryType == .faceID ? "使用 Face ID 解鎖" : "使用 Touch ID 解鎖"
    }

    // MARK: - 驗證

    private func authenticate() {
        let context = LAContext()
        var nsError: NSError?
        isAuthenticating = true

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &nsError) else {
            isAuthenticating = false
            onUnlock()
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "解鎖訂閱管家"
        ) { success, error in
            DispatchQueue.main.async {
                isAuthenticating = false
                if success {
                    errorMessage = nil
                    onUnlock()
                } else if let e = error as? LAError {
                    switch e.code {
                    case .userCancel, .systemCancel, .appCancel:
                        errorMessage = nil  // 靜默，等使用者主動點按鈕
                    case .authenticationFailed:
                        errorMessage = "驗證失敗，請再試一次"
                    default:
                        errorMessage = nil
                    }
                }
            }
        }
    }
}

#Preview {
    AppLockView { }
}
