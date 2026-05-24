import XCTest
import AnkaShared

final class EvolutionEngineTests: XCTestCase {

    func testEmptySnapshotsReturnsEvenScores() {
        let scores = EvolutionEngine.pathScores(from: [])
        XCTAssertEqual(scores.values.reduce(0, +), 1.0, accuracy: 0.01)
        for path in EvolutionPath.allCases {
            XCTAssertEqual(scores[path] ?? 0, 0.2, accuracy: 0.01)
        }
    }

    func testStepHeavyDayPicksWanderer() {
        let snap = HealthSnapshot(
            date: Date(), steps: 15_000, heartRateZoneMinutes: 5,
            standHours: 6, sleepHours: 7, workoutMinutes: 0
        )
        XCTAssertEqual(EvolutionEngine.dominantPath(from: [snap]), .wanderer)
    }

    func testWorkoutHeavyPicksMaster() {
        let snap = HealthSnapshot(
            date: Date(), steps: 2000, heartRateZoneMinutes: 10,
            standHours: 4, sleepHours: 6, workoutMinutes: 60
        )
        XCTAssertEqual(EvolutionEngine.dominantPath(from: [snap]), .master)
    }

    func testStageProgression() {
        XCTAssertEqual(EvolutionEngine.stage(forNourishment: 0), .egg)
        XCTAssertEqual(EvolutionEngine.stage(forNourishment: 2), .baby)
        XCTAssertEqual(EvolutionEngine.stage(forNourishment: 5), .young)
        XCTAssertEqual(EvolutionEngine.stage(forNourishment: 10), .adult)
        XCTAssertEqual(EvolutionEngine.stage(forNourishment: 15), .evolved)
    }
}

final class PetStoreTests: XCTestCase {
    private var suiteName: String = ""

    override func setUp() {
        super.setUp()
        suiteName = "anka.tests.\(UUID().uuidString)"
    }

    override func tearDown() {
        UserDefaults().removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testRecordSnapshotKeepsOnePerDay() async {
        let store = PetStore(suiteName: suiteName)
        let pet = PetState(species: .anka, name: "Test")
        await store.save(pet)

        // Build two timestamps that are always on the same calendar day.
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: Date())
        let morningDate = calendar.date(byAdding: .hour, value: 9, to: dayStart)!
        let eveningDate = calendar.date(byAdding: .hour, value: 20, to: dayStart)!

        let morning = HealthSnapshot(
            date: morningDate,
            steps: 1000, heartRateZoneMinutes: 0, standHours: 1, sleepHours: 0, workoutMinutes: 0
        )
        let evening = HealthSnapshot(
            date: eveningDate,
            steps: 8000, heartRateZoneMinutes: 0, standHours: 8, sleepHours: 0, workoutMinutes: 0
        )

        _ = await store.record(snapshot: morning)
        _ = await store.record(snapshot: evening)

        let loaded = await store.load()
        XCTAssertEqual(loaded?.snapshots.count, 1)
        XCTAssertEqual(loaded?.snapshots.first?.steps, 8000)
    }

    func testArchiveEvolvedCreatesRecordAndResets() async {
        let store = PetStore(suiteName: suiteName)
        let calendar = Calendar.current
        var snaps: [HealthSnapshot] = []
        for i in 0..<13 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            snaps.append(HealthSnapshot(
                date: date, steps: 15_000, heartRateZoneMinutes: 30,
                standHours: 12, sleepHours: 8, workoutMinutes: 30
            ))
        }
        let pet = PetState(species: .anka, name: "Evolver", snapshots: snaps)
        XCTAssertEqual(pet.currentStage, .evolved)

        await store.save(pet)
        let record = await store.archiveIfEvolved()
        XCTAssertNotNil(record)

        let reset = await store.load()
        XCTAssertEqual(reset?.snapshots.count, 0)
        XCTAssertEqual(reset?.hatchedHistory.count, 1)
        XCTAssertEqual(reset?.currentStage, .egg)
    }
}
