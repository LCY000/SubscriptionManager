import Foundation

struct ServicePreset: Identifiable {
    let id = UUID()
    let name: String
    let brandColorHex: String
    let defaultAmount: Decimal
    let currency: String
    let defaultCycle: BillingCycle
    let categoryName: String
    var iconAssetName: String? = nil
}

struct ServicePresetLibrary {

    struct CategoryMeta {
        let name: String
        let iconName: String
        let colorHex: String
        let sortOrder: Int
    }

    static let defaultCategories: [CategoryMeta] = [
        .init(name: "影音串流", iconName: "play.rectangle.fill", colorHex: "#E50914", sortOrder: 0),
        .init(name: "音樂",     iconName: "music.note",          colorHex: "#1DB954", sortOrder: 1),
        .init(name: "遊戲",     iconName: "gamecontroller.fill",  colorHex: "#E60012", sortOrder: 2),
        .init(name: "AI 工具",  iconName: "brain",               colorHex: "#10A37F", sortOrder: 3),
        .init(name: "生產力",   iconName: "doc.text.fill",        colorHex: "#007AFF", sortOrder: 4),
        .init(name: "雲端儲存", iconName: "icloud.fill",          colorHex: "#4285F4", sortOrder: 5),
        .init(name: "外送",     iconName: "bag.fill",             colorHex: "#06C167", sortOrder: 6),
        .init(name: "閱讀",     iconName: "book.fill",            colorHex: "#FF9500", sortOrder: 7),
        .init(name: "其他",     iconName: "tag.fill",             colorHex: "#8E8E93", sortOrder: 8),
    ]

    static let presets: [ServicePreset] = [

        // MARK: 影音串流
        .init(name: "Netflix Premium（4K）", brandColorHex: "#E50914", defaultAmount: 390,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流", iconAssetName: "logo_netflix"),
        .init(name: "Netflix 標準",          brandColorHex: "#E50914", defaultAmount: 270,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流", iconAssetName: "logo_netflix"),
        .init(name: "Disney+",               brandColorHex: "#113CCF", defaultAmount: 270,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流", iconAssetName: "logo_disney_plus"),
        .init(name: "YouTube Premium",       brandColorHex: "#FF0000", defaultAmount: 199,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流", iconAssetName: "logo_youtube"),
        .init(name: "YouTube Premium 家庭",  brandColorHex: "#FF0000", defaultAmount: 349,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流", iconAssetName: "logo_youtube"),
        .init(name: "Apple TV+",             brandColorHex: "#1C1C1E", defaultAmount: 170,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流", iconAssetName: "logo_apple_tv_plus"),
        .init(name: "Max (HBO)",             brandColorHex: "#002BE7", defaultAmount: 220,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流", iconAssetName: "logo_max_hbo"),
        .init(name: "Amazon Prime",          brandColorHex: "#FF9900", defaultAmount: 299,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流", iconAssetName: "logo_amazon_prime"),
        .init(name: "動畫瘋 Premium",        brandColorHex: "#0385B1", defaultAmount: 99,   currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流", iconAssetName: "logo_bahamut"),
        .init(name: "LINE TV",               brandColorHex: "#00B900", defaultAmount: 199,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流"),
        .init(name: "myVideo",               brandColorHex: "#0A5EB0", defaultAmount: 199,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流"),
        .init(name: "CATCHPLAY+",            brandColorHex: "#C8102E", defaultAmount: 270,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流"),
        .init(name: "friDay影音",            brandColorHex: "#F47920", defaultAmount: 199,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流"),
        .init(name: "Hami Video",            brandColorHex: "#0072C6", defaultAmount: 199,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流"),
        .init(name: "Twitch 訂閱",           brandColorHex: "#9146FF", defaultAmount: 170,  currency: "TWD", defaultCycle: .monthly, categoryName: "影音串流", iconAssetName: "logo_twitch"),

        // MARK: 音樂
        .init(name: "Spotify",               brandColorHex: "#1DB954", defaultAmount: 149,  currency: "TWD", defaultCycle: .monthly, categoryName: "音樂", iconAssetName: "logo_spotify"),
        .init(name: "Spotify 家庭方案",      brandColorHex: "#1DB954", defaultAmount: 249,  currency: "TWD", defaultCycle: .monthly, categoryName: "音樂", iconAssetName: "logo_spotify"),
        .init(name: "Apple Music",           brandColorHex: "#FA233B", defaultAmount: 170,  currency: "TWD", defaultCycle: .monthly, categoryName: "音樂", iconAssetName: "logo_apple_music"),
        .init(name: "Apple Music 家庭",      brandColorHex: "#FA233B", defaultAmount: 265,  currency: "TWD", defaultCycle: .monthly, categoryName: "音樂", iconAssetName: "logo_apple_music"),
        .init(name: "KKBOX",                 brandColorHex: "#009FE3", defaultAmount: 149,  currency: "TWD", defaultCycle: .monthly, categoryName: "音樂", iconAssetName: "logo_kkbox"),
        .init(name: "YouTube Music",         brandColorHex: "#FF0000", defaultAmount: 149,  currency: "TWD", defaultCycle: .monthly, categoryName: "音樂", iconAssetName: "logo_youtube"),
        .init(name: "TIDAL",                 brandColorHex: "#1C1C1E", defaultAmount: 300,  currency: "TWD", defaultCycle: .monthly, categoryName: "音樂", iconAssetName: "logo_tidal"),
        .init(name: "Apple Fitness+",        brandColorHex: "#FF2D55", defaultAmount: 170,  currency: "TWD", defaultCycle: .monthly, categoryName: "其他"),

        // MARK: 遊戲
        .init(name: "Nintendo Switch Online", brandColorHex: "#E60012", defaultAmount: 120,  currency: "TWD", defaultCycle: .yearly,  categoryName: "遊戲", iconAssetName: "logo_nintendo"),
        .init(name: "PlayStation Plus",       brandColorHex: "#003791", defaultAmount: 258,  currency: "TWD", defaultCycle: .monthly, categoryName: "遊戲", iconAssetName: "logo_playstation"),
        .init(name: "Xbox Game Pass",         brandColorHex: "#107C10", defaultAmount: 199,  currency: "TWD", defaultCycle: .monthly, categoryName: "遊戲", iconAssetName: "logo_xbox"),
        .init(name: "Apple Arcade",           brandColorHex: "#1A73E8", defaultAmount: 170,  currency: "TWD", defaultCycle: .monthly, categoryName: "遊戲"),
        .init(name: "Steam",                  brandColorHex: "#1B2838", defaultAmount: 0,    currency: "TWD", defaultCycle: .monthly, categoryName: "遊戲", iconAssetName: "logo_steam"),

        // MARK: AI 工具
        .init(name: "Claude Pro",         brandColorHex: "#C15F3C", defaultAmount: 660,  currency: "TWD", defaultCycle: .monthly, categoryName: "AI 工具", iconAssetName: "logo_anthropic"),
        .init(name: "ChatGPT Plus",       brandColorHex: "#10A37F", defaultAmount: 650,  currency: "TWD", defaultCycle: .monthly, categoryName: "AI 工具", iconAssetName: "logo_openai"),
        .init(name: "Gemini Advanced",    brandColorHex: "#078EFA", defaultAmount: 650,  currency: "TWD", defaultCycle: .monthly, categoryName: "AI 工具", iconAssetName: "logo_google"),
        .init(name: "Copilot Pro",        brandColorHex: "#0078D4", defaultAmount: 650,  currency: "TWD", defaultCycle: .monthly, categoryName: "AI 工具", iconAssetName: "logo_microsoft"),
        .init(name: "Perplexity Pro",     brandColorHex: "#20B2AA", defaultAmount: 650,  currency: "TWD", defaultCycle: .monthly, categoryName: "AI 工具", iconAssetName: "logo_perplexity"),
        .init(name: "Cursor Pro",         brandColorHex: "#1C1C1E", defaultAmount: 660,  currency: "TWD", defaultCycle: .monthly, categoryName: "AI 工具", iconAssetName: "logo_cursor"),
        .init(name: "Midjourney",         brandColorHex: "#1D1D1F", defaultAmount: 320,  currency: "TWD", defaultCycle: .monthly, categoryName: "AI 工具", iconAssetName: "logo_midjourney"),
        .init(name: "GitHub Copilot",     brandColorHex: "#24292E", defaultAmount: 330,  currency: "TWD", defaultCycle: .monthly, categoryName: "AI 工具", iconAssetName: "logo_github"),

        // MARK: 生產力
        .init(name: "Notion",               brandColorHex: "#1C1C1E", defaultAmount: 180,  currency: "TWD", defaultCycle: .monthly, categoryName: "生產力", iconAssetName: "logo_notion"),
        .init(name: "Microsoft 365",        brandColorHex: "#D83B01", defaultAmount: 219,  currency: "TWD", defaultCycle: .monthly, categoryName: "生產力", iconAssetName: "logo_microsoft"),
        .init(name: "Microsoft 365 家庭",   brandColorHex: "#D83B01", defaultAmount: 299,  currency: "TWD", defaultCycle: .monthly, categoryName: "生產力", iconAssetName: "logo_microsoft"),
        .init(name: "Adobe Creative Cloud", brandColorHex: "#FF0000", defaultAmount: 699,  currency: "TWD", defaultCycle: .monthly, categoryName: "生產力", iconAssetName: "logo_adobe"),
        .init(name: "Figma",                brandColorHex: "#F24E1E", defaultAmount: 480,  currency: "TWD", defaultCycle: .monthly, categoryName: "生產力", iconAssetName: "logo_figma"),
        .init(name: "1Password",            brandColorHex: "#1C6EF2", defaultAmount: 95,   currency: "TWD", defaultCycle: .monthly, categoryName: "生產力", iconAssetName: "logo_1password"),
        .init(name: "Bitwarden",            brandColorHex: "#175DDC", defaultAmount: 30,   currency: "TWD", defaultCycle: .monthly, categoryName: "生產力", iconAssetName: "logo_bitwarden"),
        .init(name: "Canva Pro",            brandColorHex: "#00C4CC", defaultAmount: 499,  currency: "TWD", defaultCycle: .monthly, categoryName: "生產力", iconAssetName: "logo_canva"),
        .init(name: "Grammarly",            brandColorHex: "#15C39A", defaultAmount: 450,  currency: "TWD", defaultCycle: .monthly, categoryName: "生產力", iconAssetName: "logo_grammarly"),
        .init(name: "Bear",                 brandColorHex: "#FC3A2F", defaultAmount: 45,   currency: "TWD", defaultCycle: .monthly, categoryName: "生產力"),

        // MARK: 雲端儲存
        .init(name: "iCloud+ 50GB",     brandColorHex: "#007AFF", defaultAmount: 30,   currency: "TWD", defaultCycle: .monthly, categoryName: "雲端儲存", iconAssetName: "logo_icloud"),
        .init(name: "iCloud+ 200GB",    brandColorHex: "#007AFF", defaultAmount: 90,   currency: "TWD", defaultCycle: .monthly, categoryName: "雲端儲存", iconAssetName: "logo_icloud"),
        .init(name: "iCloud+ 2TB",      brandColorHex: "#007AFF", defaultAmount: 330,  currency: "TWD", defaultCycle: .monthly, categoryName: "雲端儲存", iconAssetName: "logo_icloud"),
        .init(name: "iCloud+ 6TB",      brandColorHex: "#007AFF", defaultAmount: 1000, currency: "TWD", defaultCycle: .monthly, categoryName: "雲端儲存", iconAssetName: "logo_icloud"),
        .init(name: "Google One 100GB", brandColorHex: "#4285F4", defaultAmount: 65,   currency: "TWD", defaultCycle: .monthly, categoryName: "雲端儲存", iconAssetName: "logo_google"),
        .init(name: "Google One 200GB", brandColorHex: "#4285F4", defaultAmount: 99,   currency: "TWD", defaultCycle: .monthly, categoryName: "雲端儲存", iconAssetName: "logo_google"),
        .init(name: "OneDrive 100GB",   brandColorHex: "#0078D4", defaultAmount: 65,   currency: "TWD", defaultCycle: .monthly, categoryName: "雲端儲存", iconAssetName: "logo_microsoft"),
        .init(name: "Dropbox Plus",     brandColorHex: "#0061FF", defaultAmount: 399,  currency: "TWD", defaultCycle: .monthly, categoryName: "雲端儲存", iconAssetName: "logo_dropbox"),

        // MARK: 外送
        .init(name: "Uber One",      brandColorHex: "#06C167", defaultAmount: 120,  currency: "TWD", defaultCycle: .monthly, categoryName: "外送", iconAssetName: "logo_uber"),
        .init(name: "pandapro",      brandColorHex: "#D70F64", defaultAmount: 119,  currency: "TWD", defaultCycle: .monthly, categoryName: "外送", iconAssetName: "logo_foodpanda"),

        // MARK: 閱讀
        .init(name: "Kindle Unlimited", brandColorHex: "#232F3E", defaultAmount: 215, currency: "TWD", defaultCycle: .monthly, categoryName: "閱讀", iconAssetName: "logo_amazon"),
        .init(name: "readmoo 讀墨",     brandColorHex: "#70B62C", defaultAmount: 149, currency: "TWD", defaultCycle: .monthly, categoryName: "閱讀", iconAssetName: "logo_readmoo"),
        .init(name: "Audible",          brandColorHex: "#FF9900", defaultAmount: 380, currency: "TWD", defaultCycle: .monthly, categoryName: "閱讀", iconAssetName: "logo_audible"),
        .init(name: "LIS 情境英文",     brandColorHex: "#5B5FFF", defaultAmount: 199, currency: "TWD", defaultCycle: .monthly, categoryName: "閱讀"),
    ]

    static func presets(for categoryName: String) -> [ServicePreset] {
        presets.filter { $0.categoryName == categoryName }
    }
}
