import Testing
import Foundation
@testable import Final_Project_2

@Suite("SubscriptionShare Codec")
struct SubscriptionShareCodecTests {

    @Test("Round-trip：encode 後 decode 還原所有欄位")
    func roundTrip() throws {
        let payload = SharedSubscriptionPayload(
            name: "Spotify 家庭",
            amount: 240,
            currency: "TWD",
            billingCycle: .monthly,
            firstPaymentDate: Date(timeIntervalSince1970: 1_800_000_000),
            brandColorHex: "#1DB954",
            iconAssetName: "spotify",
            categoryName: "音樂",
            notes: "家庭方案",
            suggestedShare: 60
        )
        let url = try SubscriptionShareEncoder.encode(payload)
        let decoded = try SubscriptionShareDecoder.decode(url)
        #expect(decoded == payload)
    }

    @Test("URL 結構：scheme=subhub host=import 含 v 與 data")
    func urlStructure() throws {
        let payload = SharedSubscriptionPayload(
            name: "X", amount: 1, currency: "TWD", billingCycle: .monthly,
            firstPaymentDate: Date(), brandColorHex: "#000000",
            iconAssetName: nil, categoryName: nil, notes: "", suggestedShare: nil
        )
        let url = try SubscriptionShareEncoder.encode(payload)
        #expect(url.scheme == "subhub")
        #expect(url.host == "import")
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(items.contains(where: { $0.name == "v" && $0.value == "3" }))
        #expect(items.contains(where: { $0.name == "data" && $0.value != nil }))
    }

    @Test("非 subhub URL 解碼失敗")
    func wrongSchemeFails() {
        let url = URL(string: "https://example.com/import?v=1&data=abc")!
        #expect(throws: SubscriptionShareError.self) {
            try SubscriptionShareDecoder.decode(url)
        }
    }

    @Test("未知版本：丟 unsupportedVersion")
    func unsupportedVersion() {
        let url = URL(string: "subhub://import?v=999&data=abc")!
        do {
            _ = try SubscriptionShareDecoder.decode(url)
            Issue.record("expected throw")
        } catch SubscriptionShareError.unsupportedVersion(let v) {
            #expect(v == 999)
        } catch {
            Issue.record("unexpected error: \(error)")
        }
    }

    @Test("年付訂閱也能 round-trip")
    func yearlyRoundTrip() throws {
        let payload = SharedSubscriptionPayload(
            name: "iCloud+", amount: 990, currency: "TWD", billingCycle: .yearly,
            firstPaymentDate: Date(timeIntervalSince1970: 1_700_000_000),
            brandColorHex: "#0A84FF",
            iconAssetName: nil, categoryName: nil, notes: "", suggestedShare: 165
        )
        let url = try SubscriptionShareEncoder.encode(payload)
        let decoded = try SubscriptionShareDecoder.decode(url)
        #expect(decoded.billingCycle == .yearly)
        #expect(decoded.suggestedShare == 165)
    }

    @Test("suggestedShare 在 members 快照存在時仍被保留")
    func suggestedSharePreservedWithMembers() throws {
        let payload = SharedSubscriptionPayload(
            name: "YouTube Premium", amount: 219, currency: "TWD", billingCycle: .monthly,
            firstPaymentDate: Date(timeIntervalSince1970: 1_800_000_000),
            brandColorHex: "#FF0000", iconAssetName: nil, categoryName: nil, notes: "",
            suggestedShare: 80,
            organizerName: "陳小明",
            members: [
                SharedMemberInfo(name: "陳小明", amountPerCycle: 73, isOrganizer: true),
                SharedMemberInfo(name: "林小美", amountPerCycle: 73, isOrganizer: false),
            ],
            recipientName: "林小美"
        )
        let url = try SubscriptionShareEncoder.encode(payload)
        let decoded = try SubscriptionShareDecoder.decode(url)
        #expect(decoded.suggestedShare == 80)
        #expect(decoded.members?.first(where: { $0.name == "林小美" })?.amountPerCycle == 73)
    }
}
