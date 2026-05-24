import SwiftUI
import AnkaShared

struct HomeView: View {
    let pet: PetState

    var body: some View {
        TabView {
            PetDashboard(pet: pet)
                .tabItem { Label("Anka", systemImage: "sparkles") }

            AlbumView(records: pet.hatchedHistory)
                .tabItem { Label("Albüm", systemImage: "book.closed.fill") }

            LoreView()
                .tabItem { Label("Efsane", systemImage: "scroll.fill") }

            SettingsView()
                .tabItem { Label("Ayarlar", systemImage: "gearshape.fill") }
        }
        .tint(Color.ankaGold)
    }
}

struct PetDashboard: View {
    let pet: PetState

    var body: some View {
        ZStack {
            Color.ankaDeepNight.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    Text(pet.name)
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundStyle(Color.ankaGold)
                    Text("\(pet.species.displayName) · \(pet.currentStage.displayName)")
                        .font(.system(.title3, design: .serif))
                        .foregroundStyle(.white.opacity(0.7))

                    CreatureCanvas(species: pet.species, stage: pet.currentStage)
                        .frame(height: 240)

                    PathBadge(path: pet.currentPath)

                    StatsCard(pet: pet)
                }
                .padding()
            }
        }
    }
}

struct CreatureCanvas: View {
    let species: CreatureSpecies
    let stage: LifeStage

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.ankaGold.opacity(0.3), .clear],
                        center: .center,
                        startRadius: 10, endRadius: 140
                    )
                )
            // Placeholder silhouette: real illustrations land in Sprint 8.
            Text(emojiFor(species: species, stage: stage))
                .font(.system(size: 120))
        }
    }

    private func emojiFor(species: CreatureSpecies, stage: LifeStage) -> String {
        if stage == .egg { return "🥚" }
        switch species {
        case .anka:         return "🔥"
        case .sahmaran:     return "🐍"
        case .hodag:        return "🦌"
        case .karakoncolos: return "❄️"
        case .pirebatak:    return "🦊"
        }
    }
}

struct PathBadge: View {
    let path: EvolutionPath

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconFor(path))
            Text("Eğilim: \(path.displayName)")
                .font(.system(.subheadline, design: .serif))
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(
            Capsule().fill(Color.black.opacity(0.4))
                .overlay(Capsule().stroke(Color.ankaGold.opacity(0.6), lineWidth: 1))
        )
        .foregroundStyle(Color.ankaGold)
    }

    private func iconFor(_ p: EvolutionPath) -> String {
        switch p {
        case .wanderer: return "figure.walk"
        case .warrior:  return "heart.fill"
        case .sage:     return "figure.stand"
        case .dreamer:  return "moon.stars.fill"
        case .master:   return "figure.run"
        }
    }
}

struct StatsCard: View {
    let pet: PetState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bugüne kadar")
                .font(.system(.title3, design: .serif, weight: .semibold))
                .foregroundStyle(Color.ankaGold)
            HStack {
                statTile(label: "Yaş", value: "\(pet.ageInDays) gün")
                statTile(label: "Beslenme", value: "\(pet.snapshots.count) gün")
                statTile(label: "Aşama", value: pet.currentStage.displayName)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.ankaGold.opacity(0.4), lineWidth: 1)
                )
        )
    }

    private func statTile(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title3, design: .serif, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}
