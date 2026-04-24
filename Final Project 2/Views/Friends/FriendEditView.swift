import SwiftUI
import SwiftData

struct FriendEditView: View {
    var friend: Friend?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var paymentInfo: String = ""
    @State private var note: String = ""

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(friend: Friend? = nil) {
        self.friend = friend
        guard let f = friend else { return }
        _name = State(initialValue: f.name)
        _paymentInfo = State(initialValue: f.paymentInfo)
        _note = State(initialValue: f.note)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本資訊") {
                    TextField("姓名（如：林沛妤）", text: $name)
                        .autocorrectionDisabled()
                }

                Section("付款資訊") {
                    TextField("LINE ID / 銀行末 5 碼…", text: $paymentInfo)
                        .autocorrectionDisabled()
                }

                Section("備註") {
                    TextField("備註", text: $note, axis: .vertical)
                        .lineLimit(3...)
                }
            }
            .navigationTitle(friend == nil ? "新增朋友" : "編輯朋友")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("儲存", action: save)
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if let f = friend {
            f.name = trimmedName
            f.paymentInfo = paymentInfo
            f.note = note
        } else {
            let newFriend = Friend(name: trimmedName, paymentInfo: paymentInfo, note: note)
            modelContext.insert(newFriend)
        }
        dismiss()
    }
}
