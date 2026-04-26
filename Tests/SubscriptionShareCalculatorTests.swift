import Testing
import Foundation
@testable import Final_Project_2

@Suite("SubscriptionShareCalculator")
struct SubscriptionShareCalculatorTests {

    private func makeSub(
        amount: Decimal,
        cycle: BillingCycle = .monthly,
        isShared: Bool = false,
        isOrganizer: Bool = true,
        myShareOverride: Decimal? = nil
    ) -> Subscription {
        Subscription(
            name: "Test",
            amount: amount,
            billingCycle: cycle,
            firstPaymentDate: Date(),
            isShared: isShared,
            isOrganizer: isOrganizer,
            myShareOverride: myShareOverride
        )
    }

    @Test("一般訂閱：myAmount 等於 amount")
    func soloEqualsAmount() {
        let sub = makeSub(amount: 390)
        let calc = SubscriptionShareCalculator()
        #expect(calc.myAmount(for: sub) == 390)
        #expect(calc.myMonthlyShare(for: sub) == 390)
    }

    @Test("年付一般訂閱：月度等值正確")
    func yearlyMonthlyEquivalent() {
        let sub = makeSub(amount: 1788, cycle: .yearly)
        let calc = SubscriptionShareCalculator()
        #expect(calc.myAmount(for: sub) == 1788)
        #expect(calc.myMonthlyShare(for: sub) == 149)
    }

    @Test("朋友主辦：myShareOverride 覆寫")
    func friendOrganizerOverride() {
        let sub = makeSub(amount: 390, isShared: true, isOrganizer: false, myShareOverride: 100)
        let calc = SubscriptionShareCalculator()
        #expect(calc.myAmount(for: sub) == 100)
        #expect(calc.myMonthlyShare(for: sub) == 100)
    }

    @Test("override 為負時夾到零")
    func negativeOverrideClamped() {
        let sub = makeSub(amount: 390, isShared: true, isOrganizer: false, myShareOverride: -50)
        let calc = SubscriptionShareCalculator()
        #expect(calc.myAmount(for: sub) == 0)
    }

    @Test("我主辦但 plan 為 nil：退化為全額")
    func organizerWithoutPlan() {
        let sub = makeSub(amount: 390, isShared: true, isOrganizer: true)
        let calc = SubscriptionShareCalculator()
        #expect(calc.myAmount(for: sub) == 390)
    }

    @Test("我主辦 + 朋友分擔：myAmount = total - others")
    func organizerWithContributions() {
        let sub = makeSub(amount: 390, isShared: true, isOrganizer: true)
        let plan = SharedPlan(totalMembers: 4)
        plan.subscription = sub
        sub.sharedPlan = plan
        plan.contributions = [
            Contribution(amountPerMonth: 97, sharedPlan: plan),
            Contribution(amountPerMonth: 97, sharedPlan: plan),
            Contribution(amountPerMonth: 97, sharedPlan: plan),
        ]
        let calc = SubscriptionShareCalculator()
        #expect(calc.myAmount(for: sub) == 99)
    }

    @Test("朋友 contributions 加總超過 amount：夾到零")
    func othersExceedTotal() {
        let sub = makeSub(amount: 100, isShared: true, isOrganizer: true)
        let plan = SharedPlan(totalMembers: 3)
        plan.subscription = sub
        sub.sharedPlan = plan
        plan.contributions = [
            Contribution(amountPerMonth: 60, sharedPlan: plan),
            Contribution(amountPerMonth: 60, sharedPlan: plan),
        ]
        let calc = SubscriptionShareCalculator()
        #expect(calc.myAmount(for: sub) == 0)
    }

    @Test("override 優先於 isOrganizer 邏輯")
    func overrideTakesPrecedence() {
        let sub = makeSub(amount: 1000, isShared: true, isOrganizer: true, myShareOverride: 50)
        let plan = SharedPlan(totalMembers: 2)
        plan.subscription = sub
        sub.sharedPlan = plan
        plan.contributions = [Contribution(amountPerMonth: 500, sharedPlan: plan)]
        let calc = SubscriptionShareCalculator()
        #expect(calc.myAmount(for: sub) == 50)
    }

    @Test("季付主辦人分帳：myAmount 為原 cycle 金額，myMonthlyShare 換算月度")
    func quarterlyOrganizer() {
        let sub = makeSub(amount: 1170, cycle: .quarterly, isShared: true, isOrganizer: true)
        let plan = SharedPlan(totalMembers: 3)
        plan.subscription = sub
        sub.sharedPlan = plan
        plan.contributions = [
            Contribution(amountPerMonth: 390, sharedPlan: plan),
            Contribution(amountPerMonth: 390, sharedPlan: plan),
        ]
        let calc = SubscriptionShareCalculator()
        #expect(calc.myAmount(for: sub) == 390)
        #expect(calc.myMonthlyShare(for: sub) == 130)
    }
}
