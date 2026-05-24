import Foundation

/// A single day's HealthKit summary used by the EvolutionEngine.
public struct HealthSnapshot: Codable, Sendable, Equatable {
    public let date: Date
    public let steps: Int
    public let heartRateZoneMinutes: Int    // Minutes in elevated HR zones
    public let standHours: Int              // 0-12
    public let sleepHours: Double
    public let workoutMinutes: Int

    public init(
        date: Date,
        steps: Int,
        heartRateZoneMinutes: Int,
        standHours: Int,
        sleepHours: Double,
        workoutMinutes: Int
    ) {
        self.date = date
        self.steps = steps
        self.heartRateZoneMinutes = heartRateZoneMinutes
        self.standHours = standHours
        self.sleepHours = sleepHours
        self.workoutMinutes = workoutMinutes
    }

    /// Empty snapshot for a given date — useful in tests and bootstrap.
    public static func empty(on date: Date = Date()) -> HealthSnapshot {
        HealthSnapshot(
            date: date,
            steps: 0,
            heartRateZoneMinutes: 0,
            standHours: 0,
            sleepHours: 0,
            workoutMinutes: 0
        )
    }
}
