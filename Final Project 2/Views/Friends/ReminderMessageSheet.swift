import SwiftUI

struct ReminderMessageSheet: View {
    let friend: Friend
    let subscriptionName: String
    let amount: Decimal
    let currency: String

    @State private var customMessage: String = ""
    @Environment(\.dismiss) private var dismiss

    private var defaultMessage: String {
        let amountStr = amount.formatted(.currency(code: currency))
        let month = Date().formatted(.dateTime.year().month())
        return "嗨 \(friend.name)，你的 \(subscriptionName) \(month) 份 \(amountStr) 還沒給哦～ 😊"
    }

    private var messageToShare: String {
        customMessage.isEmpty ? defaultMessage : customMessage
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("預覽")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    Text(messageToShare)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.regularMaterial)
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("自訂訊息（選填）")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    TextField("留空使用預設訊息", text: $customMessage, axis: .vertical)
                        .lineLimit(4...)
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(.horizontal)
                }

                ShareLink(item: messageToShare) {
                    Label("分享催款訊息", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 14))
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top)
            .navigationTitle("催款訊息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("關閉", action: dismiss.callAsFunction)
                }
            }
        }
    }
}
