import Foundation

/// Snapshot of the pet that the UI renders. Persisted via SwiftData wrapper.
public struct PetState: Codable, Sendable, Equatable {
    public let id: UUID
    public var species: CreatureSpecies
    public var name: String
    public var bornAt: Date
    public var snapshots: [HealthSnapshot]   // rolling window, last ~14 days
    public var dominantPath: EvolutionPath?
    public var hatchedHistory: [HatchRecord]

    public init(
        id: UUID = UUID(),
        species: CreatureSpecies,
        name: String,
        bornAt: Date = Date(),
        snapshots: [HealthSnapshot] = [],
        dominantPath: EvolutionPath? = nil,
        hatchedHistory: [HatchRecord] = []
    ) {
        self.id = id
        self.species = species
        self.name = name
        self.bornAt = bornAt
        self.snapshots = snapshots
        self.dominantPath = dominantPath
        self.hatchedHistory = hatchedHistory
    }

    public var currentStage: LifeStage {
        EvolutionEngine.stage(forNourishment: EvolutionEngine.nourishment(from: snapshots))
    }

    public var currentPath: EvolutionPath {
        dominantPath ?? EvolutionEngine.dominantPath(from: snapshots)
    }

    public var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: bornAt, to: Date()).day ?? 0
    }
}

public struct HatchRecord: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let species: CreatureSpecies
    public let path: EvolutionPath
    public let bornAt: Date
    public let evolvedAt: Date

    public init(
        id: UUID = UUID(),
        species: CreatureSpecies,
        path: EvolutionPath,
        bornAt: Date,
        evolvedAt: Date
    ) {
        self.id = id
        self.species = species
        self.path = path
        self.bornAt = bornAt
        self.evolvedAt = evolvedAt
    }
}
