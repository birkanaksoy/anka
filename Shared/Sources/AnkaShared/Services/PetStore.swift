import Foundation

/// Lightweight UserDefaults-backed store for the current pet and history.
public actor PetStore {
    public static let shared = PetStore(suiteName: AppGroup.identifier)

    private let defaults: UserDefaults
    private let petKey = "anka.currentPet"

    public init(suiteName: String? = nil) {
        if let suiteName, let suite = UserDefaults(suiteName: suiteName) {
            self.defaults = suite
        } else {
            self.defaults = .standard
        }
    }

    // MARK: - Load / save

    public func load() -> PetState? {
        guard let data = defaults.data(forKey: petKey) else { return nil }
        return try? JSONDecoder().decode(PetState.self, from: data)
    }

    public func save(_ pet: PetState) {
        guard let data = try? JSONEncoder().encode(pet) else { return }
        defaults.set(data, forKey: petKey)
    }

    public func clear() {
        defaults.removeObject(forKey: petKey)
    }

    // MARK: - Snapshot recording

    /// Records today's snapshot in the rolling window. Replaces any earlier
    /// snapshot for the same calendar day so we keep at most one entry per day.
    /// Trims snapshots older than 14 days. Returns the updated pet.
    @discardableResult
    public func record(snapshot: HealthSnapshot) -> PetState? {
        guard var pet = load() else { return nil }
        let calendar = Calendar.current
        pet.snapshots.removeAll { calendar.isDate($0.date, inSameDayAs: snapshot.date) }
        pet.snapshots.append(snapshot)
        let cutoff = calendar.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        pet.snapshots.removeAll { $0.date < cutoff }
        // Refresh derived properties.
        pet.dominantPath = EvolutionEngine.dominantPath(from: pet.snapshots)
        save(pet)
        return pet
    }

    /// If the pet has reached the `.evolved` stage, archive it as a HatchRecord
    /// and return the record (along with the cleared pet). Otherwise returns nil.
    public func archiveIfEvolved() -> HatchRecord? {
        guard let pet = load() else { return nil }
        guard pet.currentStage == .evolved else { return nil }
        let record = HatchRecord(
            species: pet.species,
            path: pet.currentPath,
            bornAt: pet.bornAt,
            evolvedAt: Date()
        )
        var refreshed = pet
        refreshed.hatchedHistory.append(record)
        // Reset snapshots so the next companion starts at egg again,
        // but keep the species + name choice the player made.
        refreshed.snapshots = []
        refreshed.dominantPath = nil
        refreshed.bornAt = Date()
        save(refreshed)
        return record
    }
}
