import Foundation
import SwiftData

@Model
final class Friend {
    var id: UUID = UUID()
    var name: String = ""
    var paymentInfo: String = ""
    var note: String = ""
    var createdAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \Contribution.friend)
    var contributions: [Contribution] = []

    init(
        id: UUID = UUID(),
        name: String,
        paymentInfo: String = "",
        note: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.paymentInfo = paymentInfo
        self.note = note
        self.createdAt = createdAt
    }
}
