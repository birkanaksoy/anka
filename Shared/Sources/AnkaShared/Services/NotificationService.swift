import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

/// Sends notifications only when they help — never spammy.
///
/// Rules:
/// - Quiet hours 22:00 - 08:00: nothing fires.
/// - Daily reminder: at most one per day, at 18:00 local, and only if pet has
///   no snapshot for today yet.
/// - Evolution: one-shot celebration when the pet reaches `.evolved`.
public struct NotificationService: Sendable {
    public static let shared = NotificationService()

    public enum Category: String, Sendable {
        case dailyReminder = "anka.dailyReminder"
        case evolution = "anka.evolution"
    }

    public init() {}

    // MARK: - Authorization

    public func requestAuthorization() async -> Bool {
        #if canImport(UserNotifications)
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
        #else
        return false
        #endif
    }

    public func authorizationStatus() async -> Bool {
        #if canImport(UserNotifications)
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        #else
        return false
        #endif
    }

    // MARK: - Daily reminder

    /// Schedules a single 18:00 reminder for today if the pet has no snapshot for today.
    public func scheduleDailyReminderIfNeeded(pet: PetState) async {
        #if canImport(UserNotifications)
        guard await authorizationStatus() else { return }
        let calendar = Calendar.current
        let hasToday = pet.snapshots.contains { calendar.isDateInToday($0.date) }
        let identifier = "\(Category.dailyReminder.rawValue).\(calendar.startOfDay(for: Date()).timeIntervalSince1970)"

        // Always cancel any earlier reminder, then re-schedule if still needed.
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
        guard !hasToday else { return }
        guard let triggerTime = next6pmIfStillTodayAndAwake() else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(pet.name) is waiting"
        content.body = "A few steps will feed your \(pet.species.displayName)."
        content.sound = .default
        content.categoryIdentifier = Category.dailyReminder.rawValue

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerTime),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
        #endif
    }

    // MARK: - Evolution

    /// Fires immediately to celebrate an evolution. Quiet hours respected — if
    /// the event happens at night, the notification is deferred to 09:00.
    public func scheduleEvolutionCelebration(record: HatchRecord) async {
        #if canImport(UserNotifications)
        guard await authorizationStatus() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Your \(record.species.displayName) has evolved!"
        content.body = "Path of the \(record.path.displayName). A new egg awaits."
        content.sound = .default
        content.categoryIdentifier = Category.evolution.rawValue

        let trigger: UNNotificationTrigger
        if let deferTime = quietHoursDeferralTime() {
            let calendar = Calendar.current
            trigger = UNCalendarNotificationTrigger(
                dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: deferTime),
                repeats: false
            )
        } else {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        }

        let request = UNNotificationRequest(
            identifier: "\(Category.evolution.rawValue).\(record.id.uuidString)",
            content: content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(request)
        #endif
    }

    // MARK: - Time helpers

    /// Returns 18:00 today, but only if it's still in the future and outside
    /// quiet hours; otherwise nil.
    private func next6pmIfStillTodayAndAwake() -> Date? {
        let calendar = Calendar.current
        let now = Date()
        guard let sixPM = calendar.date(
            bySettingHour: 18, minute: 0, second: 0, of: now
        ) else { return nil }
        // Past 18:00 already? Skip; tomorrow's pipeline run will schedule again.
        guard sixPM > now else { return nil }
        // Quiet hours? Shouldn't be at 18:00 with our rules (22-8), but defensive.
        if isInQuietHours(sixPM) { return nil }
        return sixPM
    }

    /// If the current time is inside quiet hours, returns the next 09:00 to
    /// defer to. Otherwise returns nil.
    private func quietHoursDeferralTime() -> Date? {
        let now = Date()
        guard isInQuietHours(now) else { return nil }
        let calendar = Calendar.current
        let nineToday = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!
        if nineToday > now { return nineToday }
        return calendar.date(byAdding: .day, value: 1, to: nineToday)
    }

    private func isInQuietHours(_ date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 22 || hour < 8
    }
}
