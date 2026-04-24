import Foundation
import SwiftData

@Model
final class SharedPlan {
    var id: UUID = UUID()
    var totalMembers: Int = 1
    var splitMethod: SplitMethod = SplitMethod.equal
    var createdAt: Date = Date()

    var subscription: Subscription?

    @Relationship(deleteRule: .cascade, inverse: \Contribution.sharedPlan)
    var contributions: [Contribution] = []

    init(
        id: UUID = UUID(),
        totalMembers: Int,
        splitMethod: SplitMethod = .equal,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.totalMembers = totalMembers
        self.splitMethod = splitMethod
        self.createdAt = createdAt
    }
}
