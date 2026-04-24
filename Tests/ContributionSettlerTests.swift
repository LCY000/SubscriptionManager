import Testing
import Foundation
@testable import Final_Project_2

@Suite("ContributionSettler")
struct ContributionSettlerTests {

    private var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Taipei")!
        return c
    }

    private func monthStart(_ year: Int, _ month: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        return calendar.date(from: comps)!
    }

    private func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return calendar.date(from: comps)!
    }

    private func snapshot(
        prepaid: Int = 0,
        lastSettled: Date? = nil,
        status: ContributionStatus = .unpaid,
        amount: Decimal = 200
    ) -> ContributionSnapshot {
        ContributionSnapshot(
            id: UUID(),
            amountPerMonth: amount,
            prepaidMonthsRemaining: prepaid,
            lastSettledMonth: lastSettled,
            currentStatus: status
        )
    }

    @Test("Prepaid months are consumed first")
    func consumePrepaid() {
        let settler = ContributionSettler(calendar: calendar)
        let snap = snapshot(prepaid: 3)
        let result = settler.settle(snap, forMonth: monthStart(2026, 4), today: day(2026, 4, 10))
        let r = try! #require(result)
        #expect(r.outcome == .paidFromPrepay)
        #expect(r.newPrepaidMonthsRemaining == 2)
        #expect(r.newStatus == .prepaid)
        #expect(r.amount == 200)
    }

    @Test("Last prepaid month settles into paid status")
    func lastPrepaidBecomesPaid() {
        let settler = ContributionSettler(calendar: calendar)
        let snap = snapshot(prepaid: 1)
        let result = settler.settle(snap, forMonth: monthStart(2026, 4), today: day(2026, 4, 10))
        let r = try! #require(result)
        #expect(r.outcome == .paidFromPrepay)
        #expect(r.newPrepaidMonthsRemaining == 0)
        #expect(r.newStatus == .paid)
    }

    @Test("No prepay within grace period → unpaid")
    func unpaidWithinGrace() {
        let settler = ContributionSettler(calendar: calendar, overdueThresholdDays: 7)
        let snap = snapshot(prepaid: 0)
        let result = settler.settle(snap, forMonth: monthStart(2026, 4), today: day(2026, 4, 5))
        let r = try! #require(result)
        #expect(r.outcome == .unpaid)
        #expect(r.newStatus == .unpaid)
    }

    @Test("No prepay past grace period → overdue")
    func overduePastGrace() {
        let settler = ContributionSettler(calendar: calendar, overdueThresholdDays: 7)
        let snap = snapshot(prepaid: 0)
        let result = settler.settle(snap, forMonth: monthStart(2026, 4), today: day(2026, 4, 15))
        let r = try! #require(result)
        #expect(r.newStatus == .overdue)
    }

    @Test("Settle is idempotent for already-settled month")
    func settleIdempotent() {
        let settler = ContributionSettler(calendar: calendar)
        let snap = snapshot(prepaid: 0, lastSettled: monthStart(2026, 4), status: .paid)
        let result = settler.settle(snap, forMonth: monthStart(2026, 4), today: day(2026, 4, 10))
        #expect(result == nil)
    }

    @Test("catchUp from 3 months behind consumes prepaid across months")
    func catchUpConsumesPrepay() {
        let settler = ContributionSettler(calendar: calendar)
        // 粉: 預付 8 個月，上次結算到 2025/10，現在要追到 2026/4（6 個月要結算）
        let snap = snapshot(prepaid: 8, lastSettled: monthStart(2025, 10), status: .prepaid)
        let results = settler.catchUp(snap, upTo: monthStart(2026, 4), today: day(2026, 4, 21))
        #expect(results.count == 6)
        #expect(results.allSatisfy { $0.outcome == .paidFromPrepay })
        #expect(results.last!.newPrepaidMonthsRemaining == 2)
        #expect(results.last!.newStatus == .prepaid)
    }

    @Test("catchUp runs out of prepay mid-way, rest become unpaid/overdue")
    func catchUpExhaustsPrepay() {
        let settler = ContributionSettler(calendar: calendar, overdueThresholdDays: 7)
        // 預付 2 個月，要結算 5 個月：前 2 用預付、後 3 變 overdue（因為今天遠超過期日）
        let snap = snapshot(prepaid: 2, lastSettled: monthStart(2025, 11), status: .prepaid)
        let results = settler.catchUp(snap, upTo: monthStart(2026, 4), today: day(2026, 4, 21))
        #expect(results.count == 5)
        #expect(results[0].outcome == .paidFromPrepay)
        #expect(results[1].outcome == .paidFromPrepay)
        #expect(results[2].outcome == .unpaid)
        #expect(results[3].outcome == .unpaid)
        #expect(results[4].outcome == .unpaid)
        // Last one newStatus depends on today vs periodStart
        #expect(results[4].newStatus == .overdue)
    }

    @Test("catchUp from never-settled starts at target month")
    func catchUpFreshStart() {
        let settler = ContributionSettler(calendar: calendar)
        let snap = snapshot(prepaid: 0, lastSettled: nil)
        let results = settler.catchUp(snap, upTo: monthStart(2026, 4), today: day(2026, 4, 5))
        #expect(results.count == 1)
        #expect(results[0].newStatus == .unpaid)
    }

    @Test("recordManualPayment marks month as paid by hand")
    func manualPayment() {
        let settler = ContributionSettler(calendar: calendar)
        let snap = snapshot(prepaid: 0, status: .overdue)
        let result = settler.recordManualPayment(snap, forMonth: monthStart(2026, 4))
        #expect(result.outcome == .paidByHand)
        #expect(result.newStatus == .paid)
        #expect(result.newLastSettledMonth == monthStart(2026, 4))
    }

    @Test("addPrepay increments remaining and upgrades status")
    func addPrepayUpgrades() {
        let settler = ContributionSettler(calendar: calendar)
        let snap = snapshot(prepaid: 0, status: .unpaid)
        let updated = settler.addPrepay(snap, months: 4)
        #expect(updated.prepaidMonthsRemaining == 4)
        #expect(updated.currentStatus == .prepaid)
    }

    @Test("addPrepay keeps paid status if already paid")
    func addPrepayKeepsPaid() {
        let settler = ContributionSettler(calendar: calendar)
        let snap = snapshot(prepaid: 0, status: .paid)
        let updated = settler.addPrepay(snap, months: 3)
        #expect(updated.prepaidMonthsRemaining == 3)
        #expect(updated.currentStatus == .paid)
    }

    @Test("totalOutstanding sums only unpaid and overdue")
    func totalOutstanding() {
        let settler = ContributionSettler(calendar: calendar)
        let snaps: [ContributionSnapshot] = [
            snapshot(amount: 200).with(status: .unpaid),
            snapshot(amount: 210).with(status: .overdue),
            snapshot(amount: 200).with(status: .paid),
            snapshot(amount: 200).with(status: .prepaid),
        ]
        #expect(settler.totalOutstanding(for: snaps) == 410)
    }
}

private extension ContributionSnapshot {
    func with(status: ContributionStatus) -> ContributionSnapshot {
        var copy = self
        copy.currentStatus = status
        return copy
    }
}
