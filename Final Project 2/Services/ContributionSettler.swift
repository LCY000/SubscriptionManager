import Foundation

struct ContributionSnapshot: Hashable {
    var id: UUID
    var amountPerMonth: Decimal
    var prepaidMonthsRemaining: Int
    var lastSettledMonth: Date?
    var currentStatus: ContributionStatus
}

struct SettlementResult: Hashable {
    var periodStart: Date
    var outcome: SettlementOutcome
    var amount: Decimal
    var newStatus: ContributionStatus
    var newPrepaidMonthsRemaining: Int
    var newLastSettledMonth: Date
}

struct ContributionSettler {
    let calendar: Calendar
    let overdueThresholdDays: Int

    init(calendar: Calendar = .current, overdueThresholdDays: Int = 7) {
        self.calendar = calendar
        self.overdueThresholdDays = overdueThresholdDays
    }

    func settle(
        _ snapshot: ContributionSnapshot,
        forMonth monthStart: Date,
        today: Date
    ) -> SettlementResult? {
        let normalized = startOfMonth(monthStart)

        if let last = snapshot.lastSettledMonth, startOfMonth(last) >= normalized {
            return nil
        }

        let amount = snapshot.amountPerMonth

        if snapshot.prepaidMonthsRemaining > 0 {
            let remaining = snapshot.prepaidMonthsRemaining - 1
            let newStatus: ContributionStatus = remaining > 0 ? .prepaid : .paid
            return SettlementResult(
                periodStart: normalized,
                outcome: .paidFromPrepay,
                amount: amount,
                newStatus: newStatus,
                newPrepaidMonthsRemaining: remaining,
                newLastSettledMonth: normalized
            )
        }

        let status: ContributionStatus = isOverdue(periodStart: normalized, today: today) ? .overdue : .unpaid

        return SettlementResult(
            periodStart: normalized,
            outcome: .unpaid,
            amount: amount,
            newStatus: status,
            newPrepaidMonthsRemaining: 0,
            newLastSettledMonth: normalized
        )
    }

    func catchUp(
        _ snapshot: ContributionSnapshot,
        upTo targetMonth: Date,
        today: Date
    ) -> [SettlementResult] {
        var state = snapshot
        var results: [SettlementResult] = []

        let target = startOfMonth(targetMonth)

        let firstPeriod: Date
        if let last = state.lastSettledMonth {
            guard let next = calendar.date(byAdding: .month, value: 1, to: startOfMonth(last)) else {
                return []
            }
            firstPeriod = startOfMonth(next)
        } else {
            firstPeriod = target
        }

        guard firstPeriod <= target else { return [] }

        var cursor = firstPeriod
        var guardIter = 0
        while cursor <= target && guardIter < 240 {
            if let result = settle(state, forMonth: cursor, today: today) {
                results.append(result)
                state.prepaidMonthsRemaining = result.newPrepaidMonthsRemaining
                state.lastSettledMonth = result.newLastSettledMonth
                state.currentStatus = result.newStatus
            }

            guard let next = calendar.date(byAdding: .month, value: 1, to: cursor) else { break }
            cursor = startOfMonth(next)
            guardIter += 1
        }

        return results
    }

    func recordManualPayment(
        _ snapshot: ContributionSnapshot,
        forMonth monthStart: Date
    ) -> SettlementResult {
        let normalized = startOfMonth(monthStart)
        return SettlementResult(
            periodStart: normalized,
            outcome: .paidByHand,
            amount: snapshot.amountPerMonth,
            newStatus: snapshot.prepaidMonthsRemaining > 0 ? .prepaid : .paid,
            newPrepaidMonthsRemaining: snapshot.prepaidMonthsRemaining,
            newLastSettledMonth: normalized
        )
    }

    func addPrepay(
        _ snapshot: ContributionSnapshot,
        months: Int
    ) -> ContributionSnapshot {
        guard months > 0 else { return snapshot }
        var updated = snapshot
        updated.prepaidMonthsRemaining += months
        if updated.currentStatus == .unpaid || updated.currentStatus == .overdue {
            updated.currentStatus = .prepaid
        }
        return updated
    }

    func totalOutstanding(for snapshots: [ContributionSnapshot]) -> Decimal {
        snapshots.reduce(Decimal.zero) { partial, s in
            switch s.currentStatus {
            case .unpaid, .overdue:
                return partial + s.amountPerMonth
            case .paid, .prepaid:
                return partial
            }
        }
    }

    private func startOfMonth(_ date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    private func isOverdue(periodStart: Date, today: Date) -> Bool {
        let ref = calendar.startOfDay(for: today)
        let days = calendar.dateComponents([.day], from: periodStart, to: ref).day ?? 0
        return days > overdueThresholdDays
    }
}
