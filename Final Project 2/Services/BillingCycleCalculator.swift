import Foundation

struct BillingCycleCalculator {
    let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func advance(date: Date, by cycle: BillingCycle) -> Date {
        switch cycle {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: date) ?? date
        case .semiAnnual:
            return calendar.date(byAdding: .month, value: 6, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        case .customDays(let days):
            return calendar.date(byAdding: .day, value: max(1, days), to: date) ?? date
        }
    }

    func nextPaymentDate(
        firstPaymentDate: Date,
        billingCycle: BillingCycle,
        from referenceDate: Date = Date()
    ) -> Date {
        let startOfFirst = calendar.startOfDay(for: firstPaymentDate)
        let startOfRef = calendar.startOfDay(for: referenceDate)

        if startOfFirst >= startOfRef {
            return startOfFirst
        }

        var cursor = startOfFirst
        var iterations = 0
        while cursor < startOfRef && iterations < 100_000 {
            cursor = advance(date: cursor, by: billingCycle)
            iterations += 1
        }
        return cursor
    }

    func daysUntilNextPayment(
        firstPaymentDate: Date,
        billingCycle: BillingCycle,
        from referenceDate: Date = Date()
    ) -> Int {
        let next = nextPaymentDate(
            firstPaymentDate: firstPaymentDate,
            billingCycle: billingCycle,
            from: referenceDate
        )
        let refDay = calendar.startOfDay(for: referenceDate)
        return calendar.dateComponents([.day], from: refDay, to: next).day ?? 0
    }

    func monthlyEquivalent(amount: Decimal, cycle: BillingCycle) -> Decimal {
        switch cycle {
        case .weekly:
            return amount * Decimal(52) / Decimal(12)
        case .monthly:
            return amount
        case .quarterly:
            return amount / Decimal(3)
        case .semiAnnual:
            return amount / Decimal(6)
        case .yearly:
            return amount / Decimal(12)
        case .customDays(let days):
            guard days > 0 else { return amount }
            return amount * Decimal(30) / Decimal(days)
        }
    }

    func yearlyEquivalent(amount: Decimal, cycle: BillingCycle) -> Decimal {
        monthlyEquivalent(amount: amount, cycle: cycle) * Decimal(12)
    }

    func paymentDates(
        firstPaymentDate: Date,
        billingCycle: BillingCycle,
        through endDate: Date
    ) -> [Date] {
        let start = calendar.startOfDay(for: firstPaymentDate)
        let end = calendar.startOfDay(for: endDate)
        guard start <= end else { return [] }

        var result: [Date] = []
        var cursor = start
        var iterations = 0
        while cursor <= end && iterations < 10_000 {
            result.append(cursor)
            cursor = advance(date: cursor, by: billingCycle)
            iterations += 1
        }
        return result
    }
}
