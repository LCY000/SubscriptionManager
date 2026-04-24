import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Query(sort: \SubscriptionCategory.sortOrder)
    private var categories: [SubscriptionCategory]

    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false
    @State private var editingCategory: SubscriptionCategory?
    @State private var categoryToDelete: SubscriptionCategory?

    var body: some View {
        List {
            ForEach(categories) { category in
                Button {
                    editingCategory = category
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: category.iconName)
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Color(hex: category.colorHex))
                            .clipShape(.rect(cornerRadius: 8))

                        Text(category.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                            .font(.caption)
                    }
                }
            }
            .onDelete { offsets in
                guard let first = offsets.first else { return }
                categoryToDelete = categories[first]
            }
        }
        .navigationTitle("分類管理")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("新增", systemImage: "plus") { showingAddSheet = true }
            }
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            CategoryEditView()
        }
        .sheet(item: $editingCategory) { category in
            CategoryEditView(category: category)
        }
        .confirmationDialog(
            "刪除分類「\(categoryToDelete?.name ?? "")」？",
            isPresented: Binding(get: { categoryToDelete != nil }, set: { if !$0 { categoryToDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button("刪除", role: .destructive) {
                if let cat = categoryToDelete {
                    modelContext.delete(cat)
                }
                categoryToDelete = nil
            }
            Button("取消", role: .cancel) { categoryToDelete = nil }
        } message: {
            Text("使用此分類的訂閱將移至「無分類」，此操作無法復原。")
        }
    }


}

// MARK: - CategoryEditView

struct CategoryEditView: View {
    var category: SubscriptionCategory?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedIcon: String = "tag.fill"
    @State private var color: Color = .blue
    @State private var colorHex: String = "#007AFF"

    private let iconOptions: [String] = [
        "play.rectangle.fill", "music.note", "gamecontroller.fill",
        "doc.text.fill", "icloud.fill", "bag.fill", "tag.fill",
        "fork.knife", "car.fill", "house.fill", "heart.fill",
        "dumbbell.fill", "book.fill", "camera.fill", "airplane",
        "globe", "creditcard.fill", "gift.fill", "bolt.fill",
        "wifi", "tv.fill", "headphones", "pawprint.fill",
    ]

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(category: SubscriptionCategory? = nil) {
        self.category = category
        guard let cat = category else { return }
        _name = State(initialValue: cat.name)
        _selectedIcon = State(initialValue: cat.iconName)
        _colorHex = State(initialValue: cat.colorHex)
        _color = State(initialValue: Color(hex: cat.colorHex))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("名稱") {
                    TextField("分類名稱", text: $name)
                        .autocorrectionDisabled()
                }

                Section("顏色") {
                    ColorPicker("分類顏色", selection: $color)
                        .onChange(of: color) { _, newColor in
                            colorHex = newColor.toHex() ?? colorHex
                        }
                }

                Section("圖示") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title3)
                                    .foregroundStyle(selectedIcon == icon ? .white : Color(hex: colorHex))
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? Color(hex: colorHex) : Color(hex: colorHex).opacity(0.15))
                                    .clipShape(.rect(cornerRadius: 10))
                            }
                            .accessibilityLabel(icon)
                            .accessibilityAddTraits(selectedIcon == icon ? .isSelected : [])
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("預覽") {
                    HStack(spacing: 12) {
                        Image(systemName: selectedIcon)
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Color(hex: colorHex))
                            .clipShape(.rect(cornerRadius: 8))
                        Text(name.isEmpty ? "分類名稱" : name)
                            .foregroundStyle(name.isEmpty ? .secondary : .primary)
                    }
                }
            }
            .navigationTitle(category == nil ? "新增分類" : "編輯分類")
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
        if let cat = category {
            cat.name = trimmedName
            cat.iconName = selectedIcon
            cat.colorHex = colorHex
        } else {
            modelContext.insert(SubscriptionCategory(
                name: trimmedName,
                iconName: selectedIcon,
                colorHex: colorHex,
                sortOrder: 999
            ))
        }
        dismiss()
    }
}

private extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else { return nil }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

#Preview {
    NavigationStack {
        CategoryManagementView()
    }
    .modelContainer(
        for: [Subscription.self, SubscriptionCategory.self, PaymentRecord.self,
              PriceHistoryEntry.self, Friend.self, SharedPlan.self,
              Contribution.self, SettlementRecord.self],
        inMemory: true
    )
}
