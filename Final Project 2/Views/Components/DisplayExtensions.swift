import SwiftUI

extension BillingCycle {
    var displayName: String {
        switch self {
        case .weekly: "每週"
        case .monthly: "每月"
        case .quarterly: "每季"
        case .semiAnnual: "每半年"
        case .yearly: "每年"
        case .customDays(let days): "每 \(days) 天"
        }
    }
}

extension ContributionStatus {
    var displayName: String {
        switch self {
        case .paid:    "已付款"
        case .prepaid: "預付中"
        case .unpaid:  "未付款"
        case .overdue: "逾期"
        }
    }

    var accentColor: Color {
        switch self {
        case .paid:    .green
        case .prepaid: .blue
        case .unpaid:  .orange
        case .overdue: .red
        }
    }

    var iconName: String {
        switch self {
        case .paid:    "checkmark.circle.fill"
        case .prepaid: "clock.arrow.circlepath"
        case .unpaid:  "exclamationmark.circle.fill"
        case .overdue: "xmark.circle.fill"
        }
    }
}

extension SubscriptionStatus {
    var displayName: String {
        switch self {
        case .active: "啟用中"
        case .paused: "已暫停"
        case .cancelled: "已取消"
        case .trial: "試用中"
        }
    }

    var accentColor: Color {
        switch self {
        case .active: .green
        case .paused: .orange
        case .cancelled: .red
        case .trial: .blue
        }
    }

    var iconName: String {
        switch self {
        case .active: "checkmark.circle.fill"
        case .paused: "pause.circle.fill"
        case .cancelled: "xmark.circle.fill"
        case .trial: "clock.badge.fill"
        }
    }
}
