import Foundation
#if canImport(HealthKit)
import HealthKit
#endif

/// Reads the day's HealthKit summary. Safe to call on platforms without HealthKit
/// (returns an empty snapshot on macOS hosts used by SwiftPM tests).
public final class HealthKitService: Sendable {
    public static let shared = HealthKitService()

    public init() {}

    #if canImport(HealthKit)
    private let store = HKHealthStore()
    #endif

    // MARK: - Authorization

    public func requestAuthorization() async throws {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        try await store.requestAuthorization(toShare: [], read: Self.readTypes)
        #endif
    }

    public func isAuthorized() -> Bool {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        // We consider authorized if step count read is determined (granted or denied —
        // user has been asked). Real apps verify per type.
        let steps = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let status = store.authorizationStatus(for: steps)
        return status != .notDetermined
        #else
        return false
        #endif
    }

    // MARK: - Snapshot

    /// Reads today's HealthKit summary (00:00 → now).
    public func todaySnapshot() async -> HealthSnapshot {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else {
            return .empty(on: Date())
        }
        let dayStart = Calendar.current.startOfDay(for: Date())
        let now = Date()

        async let steps = totalQuantity(
            type: .stepCount, unit: .count(),
            start: dayStart, end: now,
            options: .cumulativeSum
        )
        async let standHours = totalQuantity(
            type: .appleStandTime, unit: .hour(),
            start: dayStart, end: now,
            options: .cumulativeSum
        )
        async let exerciseMinutes = totalQuantity(
            type: .appleExerciseTime, unit: .minute(),
            start: dayStart, end: now,
            options: .cumulativeSum
        )
        async let elevatedHRMinutes = self.elevatedHeartRateMinutes(start: dayStart, end: now)
        async let sleepHours = self.sleepHoursForLastNight()

        let stepsValue       = (try? await steps) ?? 0
        let standValue       = (try? await standHours) ?? 0
        let exerciseValue    = (try? await exerciseMinutes) ?? 0
        let elevatedHRValue  = (try? await elevatedHRMinutes) ?? 0
        let sleepValue       = (try? await sleepHours) ?? 0

        return HealthSnapshot(
            date: now,
            steps: Int(stepsValue),
            heartRateZoneMinutes: Int(elevatedHRValue),
            standHours: Int(standValue),
            sleepHours: sleepValue,
            workoutMinutes: Int(exerciseValue)
        )
        #else
        return .empty(on: Date())
        #endif
    }

    // MARK: - Helpers

    #if canImport(HealthKit)

    static let readTypes: Set<HKObjectType> = [
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .appleStandTime)!,
        HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
    ]

    /// Sum of a cumulative quantity type in a date window.
    private func totalQuantity(
        type identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        start: Date,
        end: Date,
        options: HKStatisticsOptions
    ) async throws -> Double {
        guard let qtyType = HKQuantityType.quantityType(forIdentifier: identifier) else { return 0 }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: qtyType,
                quantitySamplePredicate: predicate,
                options: options
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }

    /// Total minutes spent at or above 110 BPM in the window. Cheap proxy for
    /// HRV / cardio zones until we wire real Move/Exercise rings later.
    private func elevatedHeartRateMinutes(start: Date, end: Date) async throws -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return 0 }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        let unit = HKUnit.count().unitDivided(by: .minute())
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: 0)
                    return
                }
                let elevated = samples.filter { $0.quantity.doubleValue(for: unit) >= 110 }
                let totalSeconds = elevated.reduce(0.0) { acc, sample in
                    acc + sample.endDate.timeIntervalSince(sample.startDate)
                }
                continuation.resume(returning: totalSeconds / 60.0)
            }
            store.execute(query)
        }
    }

    /// Total hours of asleep state from the most recent night's window
    /// (8pm previous day → 11am today).
    private func sleepHoursForLastNight() async throws -> Double {
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard
            let windowStart = calendar.date(byAdding: .hour, value: -4, to: today),  // yesterday 8pm
            let windowEnd   = calendar.date(byAdding: .hour, value: 11, to: today)   // today 11am
        else { return 0 }
        let predicate = HKQuery.predicateForSamples(withStart: windowStart, end: windowEnd, options: [])
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0)
                    return
                }
                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue,
                    HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue
                ]
                let totalSeconds = samples
                    .filter { asleepValues.contains($0.value) }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                continuation.resume(returning: totalSeconds / 3600.0)
            }
            store.execute(query)
        }
    }
    #endif
}

public enum HealthKitError: Error, Sendable {
    case notAvailable
    case typeUnavailable(String)
}
