import Foundation
import BackgroundTasks
import AnkaShared

enum BackgroundRefresh {
    static let identifier = "com.birkanaksoy.anka.dailyRefresh"

    /// Register the BGAppRefreshTask handler. Call once at app launch.
    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { bgTask in
            let task = BGTaskBox(bgTask)
            schedule()  // reschedule next refresh

            let work = Task {
                _ = await DailyPipeline().run()
            }

            bgTask.expirationHandler = {
                work.cancel()
            }

            Task { @MainActor in
                _ = await work.value
                task.value.setTaskCompleted(success: true)
            }
        }
    }

    /// Schedule the next refresh roughly 4 hours from now. iOS decides when it
    /// actually fires (battery, network, usage patterns).
    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 4 * 3600)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Common in simulator and when running attached to Xcode — safe to ignore.
        }
    }
}

/// Wraps a BGTask so it can be passed across concurrency boundaries.
/// Safe because iOS guarantees the BGTask handler is invoked on a serial queue.
private final class BGTaskBox: @unchecked Sendable {
    let value: BGTask
    init(_ value: BGTask) { self.value = value }
}
