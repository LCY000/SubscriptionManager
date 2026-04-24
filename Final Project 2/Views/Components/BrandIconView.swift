import SwiftUI

struct BrandIconView: View {
    let name: String
    let colorHex: String
    var iconAssetName: String? = nil
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let assetName = iconAssetName,
               let localImage = UIImage(named: assetName) {
                Image(uiImage: localImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(size * 0.12)
                    .background(.white)
            } else if let assetName = iconAssetName,
                      let url = Self.clearbitURL(for: assetName) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        ZStack {
                            Color.white
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: size * 0.68, height: size * 0.68)
                        }
                    default:
                        fallbackView
                    }
                }
            } else {
                fallbackView
            }
        }
        .frame(width: size, height: size)
        .clipShape(.rect(cornerRadius: size * 0.23))
        .accessibilityHidden(true)
    }

    private var fallbackView: some View {
        Color(hex: colorHex)
            .overlay {
                Text(String(name.prefix(1)).uppercased())
                    .font(.system(size: size * 0.45, weight: .bold))
                    .foregroundStyle(.white)
            }
    }

    private static func clearbitURL(for assetName: String) -> URL? {
        guard let domain = assetNameToDomain[assetName] else { return nil }
        return URL(string: "https://t1.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=https://\(domain)&size=256")
    }

    private static let assetNameToDomain: [String: String] = [
        "logo_1password":     "1password.com",
        "logo_adobe":         "adobe.com",
        "logo_amazon":        "amazon.com",
        "logo_amazon_prime":  "primevideo.com",
        "logo_anthropic":     "anthropic.com",
        "logo_apple_music":   "music.apple.com",
        "logo_apple_tv_plus": "tv.apple.com",
        "logo_audible":       "audible.com",
        "logo_bitwarden":     "bitwarden.com",
        "logo_canva":         "canva.com",
        "logo_cursor":        "cursor.com",
        "logo_disney_plus":   "disneyplus.com",
        "logo_dropbox":       "dropbox.com",
        "logo_figma":         "figma.com",
        "logo_foodpanda":     "foodpanda.com",
        "logo_github":        "github.com",
        "logo_google":        "google.com",
        "logo_grammarly":     "grammarly.com",
        "logo_kkbox":         "kkbox.com",
        "logo_max_hbo":       "max.com",
        "logo_microsoft":     "microsoft.com",
        "logo_midjourney":    "midjourney.com",
        "logo_netflix":       "netflix.com",
        "logo_nintendo":      "nintendo.com",
        "logo_notion":        "notion.so",
        "logo_openai":        "openai.com",
        "logo_perplexity":    "perplexity.ai",
        "logo_playstation":   "playstation.com",
        "logo_readmoo":       "readmoo.com",
        "logo_spotify":       "spotify.com",
        "logo_steam":         "steampowered.com",
        "logo_tidal":         "tidal.com",
        "logo_twitch":        "twitch.tv",
        "logo_uber":          "uber.com",
        "logo_xbox":          "xbox.com",
        "logo_youtube":       "youtube.com",
        "logo_bahamut":       "ani.gamer.com.tw",
        "logo_icloud":        "icloud.com",
    ]
}

#Preview {
    HStack(spacing: 12) {
        BrandIconView(name: "Netflix",  colorHex: "#E50914", iconAssetName: "logo_netflix")
        BrandIconView(name: "Spotify",  colorHex: "#1DB954", iconAssetName: "logo_spotify")
        BrandIconView(name: "YouTube",  colorHex: "#FF0000", iconAssetName: "logo_youtube", size: 56)
        BrandIconView(name: "iCloud",   colorHex: "#007AFF", size: 32)
    }
    .padding()
}
