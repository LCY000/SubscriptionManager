import SwiftUI

struct ServicePresetPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (ServicePreset) -> Void

    @State private var selectedCategory: String = ServicePresetLibrary.defaultCategories[0].name

    private var currentCategoryMeta: ServicePresetLibrary.CategoryMeta? {
        ServicePresetLibrary.defaultCategories.first { $0.name == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryPicker
                Divider()
                presetList
            }
            .navigationTitle("選擇服務")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消", action: dismiss.callAsFunction)
                }
            }
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ServicePresetLibrary.defaultCategories, id: \.name) { meta in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedCategory = meta.name
                        }
                    } label: {
                        Text(meta.name)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(selectedCategory == meta.name ? Color(hex: meta.colorHex) : Color(.systemGray5))
                            .foregroundStyle(selectedCategory == meta.name ? .white : .primary)
                            .clipShape(.capsule)
                    }
                    .accessibilityAddTraits(selectedCategory == meta.name ? .isSelected : [])
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }

    private var presetList: some View {
        let presets = ServicePresetLibrary.presets(for: selectedCategory)
        return Group {
            if presets.isEmpty {
                ContentUnavailableView {
                    Label("此分類暫無內建服務", systemImage: "tray")
                } description: {
                    Text("可在訂閱列表直接新增自訂服務")
                }
            } else {
                List(presets) { preset in
                    Button {
                        onSelect(preset)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            BrandIconView(name: preset.name, colorHex: preset.brandColorHex, iconAssetName: preset.iconAssetName)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(preset.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("\(preset.defaultAmount.formatted(.currency(code: preset.currency))) / \(String(preset.defaultCycle.displayName.dropFirst()))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                                .font(.caption)
                        }
                    }
                    .accessibilityLabel("\(preset.name)，\(preset.defaultAmount.formatted(.currency(code: preset.currency)))，\(preset.defaultCycle.displayName)")
                }
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
    ServicePresetPickerView { _ in }
}
