import UserNotifications
import Foundation

struct ReminderScheduler {

    // MARK: - Permission

    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - Schedule

    /// Cancels existing reminders for the subscription then schedules new ones.
    static func schedule(for subscription: Subscription) async {
        let center = UNUserNotificationCenter.current()
        await cancelPending(id: subscription.id, in: center)

        guard subscription.status == .active || subscription.status == .trial else { return }

        await schedulePaymentReminder(for: subscription, in: center)

        if subscription.status == .trial {
            await scheduleTrialReminder(for: subscription, in: center)
        }
    }

    // MARK: - Cancel

    static func cancel(for subscriptionId: UUID) async {
        await cancelPending(id: subscriptionId, in: UNUserNotificationCenter.current())
    }

    // MARK: - Private

    private static func schedulePaymentReminder(
        for subscription: Subscription,
        in center: UNUserNotificationCenter
    ) async {
        guard subscription.reminderDaysBefore > 0 else { return }

        let calculator = BillingCycleCalculator()
        let nextPayment = calculator.nextPaymentDate(
            firstPaymentDate: subscription.firstPaymentDate,
            billingCycle: subscription.billingCycle
        )

        guard let triggerDay = Calendar.current.date(
            byAdding: .day, value: -subscription.reminderDaysBefore, to: nextPayment
        ) else { return }

        let dayStart = Calendar.current.startOfDay(for: triggerDay)
        let storedHour = UserDefaults.standard.integer(forKey: "notificationHour")
        let hour = storedHour == 0 ? 9 : storedHour
        let fireDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: dayStart) ?? dayStart
        guard fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = subscription.name
        content.body = subscription.reminderDaysBefore == 1
            ? "明天將扣款 \(subscription.amount.formatted(.currency(code: subscription.currency)))"
            : "\(subscription.reminderDaysBefore) 天後將扣款 \(subscription.amount.formatted(.currency(code: subscription.currency)))"
        content.sound = .default

        let identifier = "sub_\(subscription.id)_\(Int(fireDate.timeIntervalSince1970))"
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
    }

    private static func scheduleTrialReminder(
        for subscription: Subscription,
        in center: UNUserNotificationCenter
    ) async {
        guard let trialEnd = subscription.trialEndDate else { return }
        // 試用提醒至少提前 2 天，尊重 reminderDaysBefore 但下限為 2
        let daysBefore = max(subscription.reminderDaysBefore, 2)

        guard let triggerDay = Calendar.current.date(
            byAdding: .day, value: -daysBefore, to: trialEnd
        ) else { return }

        let dayStart = Calendar.current.startOfDay(for: triggerDay)
        let storedHour = UserDefaults.standard.integer(forKey: "notificationHour")
        let hour = storedHour == 0 ? 9 : storedHour
        let fireDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: dayStart) ?? dayStart
        guard fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "試用即將到期：\(subscription.name)"
        content.body = "\(daysBefore) 天後試用期結束，屆時將自動扣款 \(subscription.amount.formatted(.currency(code: subscription.currency)))"
        content.sound = .default

        let identifier = "trial_\(subscription.id)_\(Int(fireDate.timeIntervalSince1970))"
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
    }

    private static func cancelPending(id: UUID, in center: UNUserNotificationCenter) async {
        let idString = id.uuidString
        let pending = await center.pendingNotificationRequests()
        let toRemove = pending.compactMap { req -> String? in
            (req.identifier.hasPrefix("sub_\(idString)") || req.identifier.hasPrefix("trial_\(idString)"))
                ? req.identifier : nil
        }
        center.removePendingNotificationRequests(withIdentifiers: toRemove)
    }
}
