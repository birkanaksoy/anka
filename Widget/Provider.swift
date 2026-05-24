import WidgetKit
import Foundation
import AnkaShared

struct AnkaEntry: TimelineEntry {
    let date: Date
    let pet: PetState?
    let nourishment: Double  // 0.0 ... 1.0

    static let placeholder = AnkaEntry(
        date: Date(),
        pet: PetState(species: .anka, name: "Anka"),
        nourishment: 0.4
    )
}

struct AnkaTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> AnkaEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (AnkaEntry) -> Void) {
        completion(currentEntry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<AnkaEntry>) -> Void) {
        let now = Date()
        let entry = currentEntry(at: now)
        // Refresh every 30 minutes — WidgetKit may coalesce.
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: now) ?? now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    /// Synchronously reads the shared PetState from the App Group UserDefaults.
    /// Safe because UserDefaults reads are atomic and we only consume Codable bytes.
    private func currentEntry(at date: Date) -> AnkaEntry {
        let pet = WidgetPetReader.load()
        let nourishment: Double
        if let pet {
            let n = EvolutionEngine.nourishment(from: pet.snapshots)
            nourishment = min(n / 12.0, 1.0)
        } else {
            nourishment = 0
        }
        return AnkaEntry(date: date, pet: pet, nourishment: nourishment)
    }
}

/// Synchronous read path for widget extensions. Mirrors PetStore's key/format.
private enum WidgetPetReader {
    static func load() -> PetState? {
        guard let defaults = UserDefaults(suiteName: AppGroup.identifier),
              let data = defaults.data(forKey: "anka.currentPet") else { return nil }
        return try? JSONDecoder().decode(PetState.self, from: data)
    }
}
