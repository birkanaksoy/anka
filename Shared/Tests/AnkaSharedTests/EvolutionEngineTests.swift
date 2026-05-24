import XCTest
@testable import AnkaShared

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
            date: Date(),
            steps: 15_000,
            heartRateZoneMinutes: 5,
            standHours: 6,
            sleepHours: 7,
            workoutMinutes: 0
        )
        XCTAssertEqual(EvolutionEngine.dominantPath(from: [snap]), .wanderer)
    }

    func testWorkoutHeavyPicksMaster() {
        let snap = HealthSnapshot(
            date: Date(),
            steps: 2000,
            heartRateZoneMinutes: 10,
            standHours: 4,
            sleepHours: 6,
            workoutMinutes: 60
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

    func testNourishmentScalesWithDays() {
        let strongDay = HealthSnapshot(
            date: Date(), steps: 12_000, heartRateZoneMinutes: 30,
            standHours: 12, sleepHours: 8, workoutMinutes: 30
        )
        let n1 = EvolutionEngine.nourishment(from: [strongDay])
        let n7 = EvolutionEngine.nourishment(from: Array(repeating: strongDay, count: 7))
        XCTAssertGreaterThan(n7, n1)
    }

    func testPetStateExposesCurrentStageAndPath() {
        let strongStep = HealthSnapshot(
            date: Date(), steps: 12_000, heartRateZoneMinutes: 0,
            standHours: 0, sleepHours: 0, workoutMinutes: 0
        )
        let pet = PetState(
            species: .anka,
            name: "Ankara",
            snapshots: Array(repeating: strongStep, count: 10)
        )
        XCTAssertEqual(pet.currentPath, .wanderer)
        XCTAssertGreaterThanOrEqual(pet.currentStage, .young)
    }
}

final class PetStoreTests: XCTestCase {
    private let suiteName = "anka.tests.\(UUID().uuidString)"

    override func tearDown() async throws {
        UserDefaults().removePersistentDomain(forName: suiteName)
    }

    func testRecordSnapshotReplacesSameCalendarDay() async {
        let store = PetStore(suiteName: suiteName)
        let pet = PetState(species: .anka, name: "Test")
        await store.save(pet)

        let morning = HealthSnapshot(
            date: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
            steps: 1000, heartRateZoneMinutes: 0,
            standHours: 1, sleepHours: 0, workoutMinutes: 0
        )
        let evening = HealthSnapshot(
            date: Date(),
            steps: 8000, heartRateZoneMinutes: 0,
            standHours: 8, sleepHours: 0, workoutMinutes: 0
        )

        await store.record(snapshot: morning)
        await store.record(snapshot: evening)

        let loaded = await store.load()
        XCTAssertEqual(loaded?.snapshots.count, 1, "Same day should keep only the latest snapshot")
        XCTAssertEqual(loaded?.snapshots.first?.steps, 8000)
    }

    func testArchiveIfEvolvedCreatesRecordAndResetsSnapshots() async {
        let store = PetStore(suiteName: suiteName)
        let strongDay = HealthSnapshot(
            date: Date(), steps: 15_000, heartRateZoneMinutes: 30,
            standHours: 12, sleepHours: 8, workoutMinutes: 30
        )
        // Fabricate snapshots from different days to satisfy the rolling window.
        let calendar = Calendar.current
        var snaps: [HealthSnapshot] = []
        for i in 0..<13 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            snaps.append(HealthSnapshot(
                date: date, steps: strongDay.steps,
                heartRateZoneMinutes: strongDay.heartRateZoneMinutes,
                standHours: strongDay.standHours,
                sleepHours: strongDay.sleepHours,
                workoutMinutes: strongDay.workoutMinutes
            ))
        }
        let pet = PetState(species: .anka, name: "Evolver", snapshots: snaps)
        XCTAssertEqual(pet.currentStage, .evolved, "Setup precondition")

        await store.save(pet)
        let record = await store.archiveIfEvolved()
        XCTAssertNotNil(record)
        XCTAssertEqual(record?.species, .anka)

        let reset = await store.load()
        XCTAssertEqual(reset?.snapshots.count, 0)
        XCTAssertEqual(reset?.hatchedHistory.count, 1)
        XCTAssertEqual(reset?.currentStage, .egg)
    }
}
