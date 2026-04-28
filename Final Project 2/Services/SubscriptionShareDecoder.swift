import Foundation

struct SubscriptionShareDecoder {
    static func decode(_ url: URL) throws -> SharedSubscriptionPayload {
        guard
            url.scheme == SubscriptionShareEncoder.scheme,
            url.host == SubscriptionShareEncoder.host,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            throw SubscriptionShareError.decodingFailed
        }

        let items = components.queryItems ?? []
        guard
            let versionString = items.first(where: { $0.name == "v" })?.value,
            let version = Int(versionString),
            let base64 = items.first(where: { $0.name == "data" })?.value
        else {
            throw SubscriptionShareError.decodingFailed
        }

        guard version <= SharedSubscriptionPayload.currentVersion else {
            throw SubscriptionShareError.unsupportedVersion(version)
        }

        let normalized = base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padded = normalized.padding(
            toLength: ((normalized.count + 3) / 4) * 4,
            withPad: "=",
            startingAt: 0
        )
        guard let rawData = Data(base64Encoded: padded) else {
            throw SubscriptionShareError.decodingFailed
        }
        guard let data = try? (rawData as NSData).decompressed(using: .zlib) as Data else {
            throw SubscriptionShareError.decodingFailed
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SharedSubscriptionPayload.self, from: data)
    }
}
