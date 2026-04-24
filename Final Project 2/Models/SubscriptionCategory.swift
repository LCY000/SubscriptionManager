import Foundation
import SwiftData

@Model
final class SubscriptionCategory {
    var id: UUID = UUID()
    var name: String = ""
    var iconName: String = "tag"
    var colorHex: String = "#8E8E93"
    var sortOrder: Int = 0
    var createdAt: Date = Date()

    var subscriptions: [Subscription] = []

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = "tag",
        colorHex: String = "#8E8E93",
        sortOrder: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }
}
