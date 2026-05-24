import XCTest
import AnkaShared

final class AnkaTests: XCTestCase {
    func testCreatureSpeciesHasDisplayName() {
        for species in CreatureSpecies.allCases {
            XCTAssertFalse(species.displayName.isEmpty)
            XCTAssertFalse(species.loreShort.isEmpty)
        }
    }

    func testEvolutionPathHasDisplayName() {
        for path in EvolutionPath.allCases {
            XCTAssertFalse(path.displayName.isEmpty)
        }
    }

    func testPetStateCodableRoundtrip() throws {
        let pet = PetState(
            species: .anka,
            name: "Test",
            snapshots: [HealthSnapshot.empty()]
        )
        let data = try JSONEncoder().encode(pet)
        let decoded = try JSONDecoder().decode(PetState.self, from: data)
        XCTAssertEqual(decoded.name, "Test")
        XCTAssertEqual(decoded.species, .anka)
        XCTAssertEqual(decoded.snapshots.count, 1)
    }
}
