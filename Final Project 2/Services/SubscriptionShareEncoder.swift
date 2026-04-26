// 深層連結分享編碼器
//
// 注意：要讓 subhub:// URL 在 LINE / iMessage 點擊後喚起 App，需在 Xcode
// → Final Project 2 target → Info → URL Types 加入：
//   - URL Schemes: subhub
//   - Identifier: work.Final-Project-2.share

import Foundation

enum SubscriptionShareError: Error {
    case encodingFailed
    case decodingFailed
    case unsupportedVersion(Int)
    case payloadTooLarge
}

struct SubscriptionShareEncoder {
    static let scheme = "subhub"
    static let host = "import"
    private static let maxPayloadBytes = 4096

    static func encode(_ subscription: Subscription, suggestedShare: Decimal? = nil) throws -> URL {
        let payload = SharedSubscriptionPayload(
            name: subscription.name,
            amount: subscription.amount,
            currency: subscription.currency,
            billingCycle: subscription.billingCycle,
            firstPaymentDate: subscription.firstPaymentDate,
            brandColorHex: subscription.brandColorHex,
            iconAssetName: subscription.iconAssetName,
            categoryName: subscription.category?.name,
            notes: subscription.notes,
            suggestedShare: suggestedShare ?? SubscriptionShareCalculator().myAmount(for: subscription)
        )
        return try encode(payload)
    }

    static func encode(_ payload: SharedSubscriptionPayload) throws -> URL {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        guard data.count <= maxPayloadBytes else { throw SubscriptionShareError.payloadTooLarge }

        let base64 = data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.queryItems = [
            URLQueryItem(name: "v", value: String(payload.version)),
            URLQueryItem(name: "data", value: base64),
        ]
        guard let url = components.url else { throw SubscriptionShareError.encodingFailed }
        return url
    }
}
