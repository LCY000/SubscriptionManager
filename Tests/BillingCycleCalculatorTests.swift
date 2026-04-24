import Testing
import Foundation
@testable import Final_Project_2

@Suite("BillingCycleCalculator")
struct BillingCycleCalculatorTests {

    private var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Taipei")!
        return c
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return calendar.date(from: comps)!
    }

    @Test("Monthly from Jan 31 lands on Feb 28 in non-leap year")
    func monthEndNonLeap() {
        let calc = BillingCycleCalculator(calendar: calendar)
        let jan31 = date(2026, 1, 31)
        let feb = calc.advance(date: jan31, by: .monthly)
        #expect(calendar.startOfDay(for: feb) == date(2026, 2, 28))
    }

    @Test("Monthly from Jan 31 lands on Feb 29 in leap year")
    func monthEndLeapYear() {
        let calc = BillingCycleCalculator(calendar: calendar)
        let jan31 = date(2028, 1, 31)
        let feb = calc.advance(date: jan31, by: .monthly)
        #expect(calendar.startOfDay(for: feb) == date(2028, 2, 29))
    }

    @Test("Yearly from Feb 29 in leap year lands on Feb 28 next year")
    func yearlyFromLeapDay() {
        let calc = BillingCycleCalculator(calendar: calendar)
        let leap = date(2024, 2, 29)
        let next = calc.advance(date: leap, by: .yearly)
        #expect(calendar.startOfDay(for: next) == date(2025, 2, 28))
    }

    @Test("Weekly advances by 7 days")
    func weeklyAdvance() {
        let calc = BillingCycleCalculator(calendar: calendar)
        let start = date(2026, 4, 10)
        let next = calc.advance(date: start, by: .weekly)
        #expect(calendar.startOfDay(for: next) == date(2026, 4, 17))
    }

    @Test("Custom 14 days advances by 14 days")
    func customDaysAdvance() {
        let calc = BillingCycleCalculator(calendar: calendar)
        let start = date(2026, 4, 10)
        let next = calc.advance(date: start, by: .customDays(14))
        #expect(calendar.startOfDay(for: next) == date(2026, 4, 24))
    }

    @Test("Quarterly advances by 3 months")
    func quarterlyAdvance() {
        let calc = BillingCycleCalculator(calendar: calendar)
        let start = date(2026, 1, 15)
        let next = calc.advance(date: start, by: .quarterly)
        #expect(calendar.startOfDay(for: next) == date(2026, 4, 15))
    }

    @Test("nextPaymentDate returns firstPaymentDate when it is in the future")
    func nextFutureFirst() {
        let calc = BillingCycleCalculator(calendar: calendar)
        let first = date(2027, 1, 1)
        let today = date(2026, 4, 21)
        let next = calc.nextPaymentDate(firstPaymentDate: first, billingCycle: .monthly, from: today)
        #expect(calendar.startOfDay(for: next) == date(2027, 1, 1))
    }

    @Test("nextPaymentDate rolls forward past reference date")
    func nextRollsForward() {
        let calc = BillingCycleCalculator(calendar: calendar)
        let first = date(2026, 1, 15)
        let today = date(2026, 4, 20)
        let next = calc.nextPaymentDate(firstPaymentDate: first, billingCycle: .monthly, from: today)
        #expect(calendar.startOfDay(for: next) == date(2026, 5, 15))
    }

    @Test("nextPaymentDate returns today when firstPaymentDate equals today")
    func nextEqualsToday() {
        let calc = BillingCycleCalculator(calendar: calendar)
        let today = date(2026, 4, 21)
        let next = calc.nextPaymentDate(firstPaymentDate: today, billingCycle: .monthly, from: today)
        #expect(calendar.startOfDay(for: next) == today)
    }

    @Test("daysUntilNextPayment computes correct gap")
    func daysUntilNext() {
        let calc = BillingCycleCalculator(calendar: calendar)
        let first = date(2026, 4, 25)
        let today = date(2026, 4, 21)
        let days = calc.daysUntilNextPayment(firstPaymentDate: first, billingCycle: .monthly, from: today)
        #expect(days == 4)
    }

    @Test("monthlyEquivalent for each cycle")
    func monthlyEquivalents() {
        let calc = BillingCycleCalculator(calendar: calendar)
        #expect(calc.monthlyEquivalent(amount: 120, cycle: .monthly) == 120)
        #expect(calc.monthlyEquivalent(amount: 1200, cycle: .yearly) == 100)
        #expect(calc.monthlyEquivalent(amount: 300, cycle: .quarterly) == 100)
        #expect(calc.monthlyEquivalent(amount: 600, cycle: .semiAnnual) == 100)
        // weekly 100 * 52 / 12 ≈ 433.33
        let weekly = calc.monthlyEquivalent(amount: 100, cycle: .weekly)
        let diff = weekly - Decimal(433)
        #expect(diff > 0 && diff < 1)
    }

    @Test("yearlyEquivalent returns monthly * 12")
    func yearlyEquivalents() {
        let calc = BillingCycleCalculator(calendar: calendar)
        #expect(calc.yearlyEquivalent(amount: 120, cycle: .monthly) == 1440)
        #expect(calc.yearlyEquivalent(amount: 1200, cycle: .yearly) == 1200)
    }

    @Test("paymentDates generates all occurrences in range")
    func paymentDatesRange() {
        let calc = BillingCycleCalculator(calendar: calendar)
        let first = date(2026, 1, 15)
        let end = date(2026, 4, 20)
        let dates = calc.paymentDates(firstPaymentDate: first, billingCycle: .monthly, through: end)
        #expect(dates.count == 4)
        #expect(dates[0] == date(2026, 1, 15))
        #expect(dates[3] == date(2026, 4, 15))
    }
}
