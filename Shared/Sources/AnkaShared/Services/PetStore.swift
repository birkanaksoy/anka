import Foundation

/// Lightweight UserDefaults-backed store for the current pet.
/// In Phase 2 this will be replaced by SwiftData with App Group sync.
public actor PetStore {
    public static let shared = PetStore()

    private let defaults: UserDefaults
    private let key = "anka.currentPet"

    public init(suiteName: String? = nil) {
        if let suiteName, let suite = UserDefaults(suiteName: suiteName) {
            self.defaults = suite
        } else {
            self.defaults = .standard
        }
    }

    public func load() -> PetState? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(PetState.self, from: data)
    }

    public func save(_ pet: PetState) {
        guard let data = try? JSONEncoder().encode(pet) else { return }
        defaults.set(data, forKey: key)
    }

    public func clear() {
        defaults.removeObject(forKey: key)
    }

    /// Append today's snapshot and trim to a rolling 14-day window.
    public func record(snapshot: HealthSnapshot) {
        guard var pet = load() else { return }
        pet.snapshots.append(snapshot)
        let cutoff = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        pet.snapshots.removeAll { $0.date < cutoff }
        save(pet)
    }
}
