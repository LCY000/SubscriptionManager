import Foundation
import SwiftData

struct ContributionSettlerService {
    private static let settler = ContributionSettler()

    // MARK: - Catch-up to current month

    static func catchUpToCurrentMonth(contribution: Contribution, context: ModelContext) {
        let today = Date()
        let currentMonthStart = startOfMonth(today)
        let results = settler.catchUp(contribution.asSnapshot(), upTo: currentMonthStart, today: today)
        guard !results.isEmpty else { return }

        if let last = results.last {
            contribution.prepaidMonthsRemaining = last.newPrepaidMonthsRemaining
            contribution.lastSettledMonth = last.newLastSettledMonth
            contribution.currentStatus = last.newStatus
        }
        for result in results {
            let record = SettlementRecord(
                periodStart: result.periodStart,
                amount: result.amount,
                outcome: result.outcome,
                contribution: contribution
            )
            context.insert(record)
        }
    }

    // MARK: - Manual payment

    static func markAsPaid(contribution: Contribution, forMonth month: Date = Date(), context: ModelContext) {
        let result = settler.recordManualPayment(contribution.asSnapshot(), forMonth: month)
        contribution.currentStatus = result.newStatus
        contribution.lastSettledMonth = result.newLastSettledMonth
        let record = SettlementRecord(
            periodStart: result.periodStart,
            amount: result.amount,
            outcome: result.outcome,
            contribution: contribution
        )
        context.insert(record)
    }

    // MARK: - Prepay

    static func addPrepay(contribution: Contribution, months: Int) {
        guard months > 0 else { return }
        let updated = settler.addPrepay(contribution.asSnapshot(), months: months)
        contribution.prepaidMonthsRemaining = updated.prepaidMonthsRemaining
        contribution.currentStatus = updated.currentStatus
    }

    // MARK: - Helpers

    static func totalOutstanding(for contributions: [Contribution]) -> Decimal {
        settler.totalOutstanding(for: contributions.map { $0.asSnapshot() })
    }

    private static func startOfMonth(_ date: Date) -> Date {
        let comps = Calendar.current.dateComponents([.year, .month], from: date)
        return Calendar.current.date(from: comps) ?? date
    }
}

extension Contribution {
    func asSnapshot() -> ContributionSnapshot {
        ContributionSnapshot(
            id: id,
            amountPerMonth: amountPerMonth,
            prepaidMonthsRemaining: prepaidMonthsRemaining,
            lastSettledMonth: lastSettledMonth,
            currentStatus: currentStatus
        )
    }
}
