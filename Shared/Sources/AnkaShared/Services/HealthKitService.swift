import Foundation
#if canImport(HealthKit)
import HealthKit
#endif

/// Reads the day's HealthKit summary. Safe to call on platforms without HealthKit
/// (simulator and tests get a stubbed snapshot).
public final class HealthKitService: Sendable {
    public static let shared = HealthKitService()

    public init() {}

    #if canImport(HealthKit)
    private let store = HKHealthStore()
    #endif

    public func requestAuthorization() async throws {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let read: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .appleStandTime)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        try await store.requestAuthorization(toShare: [], read: read)
        #endif
    }

    /// Read today's snapshot. Currently returns a placeholder; real queries land in Sprint 2.
    public func todaySnapshot() async -> HealthSnapshot {
        // TODO: real HKStatisticsQuery + HKSampleQuery wiring.
        HealthSnapshot.empty(on: Date())
    }
}
