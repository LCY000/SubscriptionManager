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

    static func encode(_ subscription: Subscription, suggestedShare: Decimal? = nil, recipientName: String? = nil) throws -> URL {
        let nickname = UserDefaults.standard.string(forKey: "userNickname")
        let myAmt = SubscriptionShareCalculator().myAmount(for: subscription)

        var organizerName: String? = nil
        var members: [SharedMemberInfo]? = nil

        if subscription.isOrganizer, let plan = subscription.sharedPlan {
            var list: [SharedMemberInfo] = []
            if let nick = nickname, !nick.isEmpty {
                organizerName = nick
                list.append(.init(name: nick, amountPerCycle: myAmt, isOrganizer: true))
            }
            for c in plan.contributions {
                if let n = c.friend?.name {
                    list.append(.init(name: n, amountPerCycle: c.amountPerMonth, isOrganizer: false))
                }
            }
            members = list.isEmpty ? nil : list
        }

        let shareAmount: Decimal
        if let explicit = suggestedShare {
            shareAmount = explicit
        } else if let recipientName,
                  let plan = subscription.sharedPlan,
                  let c = plan.contributions.first(where: { $0.friend?.name == recipientName }) {
            shareAmount = c.amountPerMonth
        } else {
            shareAmount = myAmt
        }

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
            suggestedShare: shareAmount,
            organizerName: organizerName,
            members: members,
            recipientName: recipientName
        )
        return try encode(payload)
    }

    static func encode(_ payload: SharedSubscriptionPayload) throws -> URL {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(payload)
        guard jsonData.count <= maxPayloadBytes else { throw SubscriptionShareError.payloadTooLarge }

        guard let compressedData = try? (jsonData as NSData).compressed(using: .zlib) as Data else {
            throw SubscriptionShareError.encodingFailed
        }

        let base64 = compressedData.base64EncodedString()
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
