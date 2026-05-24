import Foundation

/// Orchestrates the once-per-app-open flow:
/// 1. Read today's HealthKit snapshot
/// 2. Record it in the store (one per calendar day)
/// 3. Detect evolution and archive if needed
public struct DailyPipeline: Sendable {
    public let health: HealthKitService
    public let store: PetStore

    public init(
        health: HealthKitService = .shared,
        store: PetStore = .shared
    ) {
        self.health = health
        self.store = store
    }

    public struct Result: Sendable {
        public let snapshot: HealthSnapshot
        public let pet: PetState?
        public let evolved: HatchRecord?
    }

    @discardableResult
    public func run() async -> Result {
        let snapshot = await health.todaySnapshot()
        let pet = await store.record(snapshot: snapshot)
        let evolved = await store.archiveIfEvolved()
        let final = evolved == nil ? pet : await store.load()
        return Result(snapshot: snapshot, pet: final, evolved: evolved)
    }
}
