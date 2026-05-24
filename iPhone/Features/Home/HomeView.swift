import SwiftUI
import AnkaShared

struct HomeView: View {
    let pet: PetState
    let todaySnapshot: HealthSnapshot?

    var body: some View {
        TabView {
            PetDashboard(pet: pet, todaySnapshot: todaySnapshot)
                .tabItem { Label("Companion", systemImage: "sparkles") }

            AlbumView(records: pet.hatchedHistory)
                .tabItem { Label("Album", systemImage: "book.closed.fill") }

            LoreView()
                .tabItem { Label("Lore", systemImage: "scroll.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Color.ankaGold)
    }
}

struct PetDashboard: View {
    let pet: PetState
    let todaySnapshot: HealthSnapshot?

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

                    if let todaySnapshot {
                        TodayCard(snapshot: todaySnapshot)
                    } else {
                        EmptyTodayCard()
                    }

                    StatsCard(pet: pet)
                }
                .padding()
            }
        }
    }
}

struct EmptyTodayCard: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.text.square")
                .font(.title2)
                .foregroundStyle(Color.ankaGold.opacity(0.6))
            Text("Grant Health access in Settings\nto feed your Anka.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.ankaGold.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

struct TodayCard: View {
    let snapshot: HealthSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.system(.title3, design: .serif, weight: .semibold))
                .foregroundStyle(Color.ankaGold)
                .accessibilityAddTraits(.isHeader)
            HStack {
                metric(label: "Steps", value: "\(snapshot.steps)", icon: "figure.walk")
                metric(label: "HR min", value: "\(snapshot.heartRateZoneMinutes)", icon: "heart.fill")
                metric(label: "Stand", value: "\(snapshot.standHours)", icon: "figure.stand")
            }
            HStack {
                metric(label: "Sleep", value: String(format: "%.1f h", snapshot.sleepHours), icon: "moon.stars.fill")
                metric(label: "Workout", value: "\(snapshot.workoutMinutes) m", icon: "figure.run")
                Spacer().frame(maxWidth: .infinity)
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

    private func metric(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(Color.ankaGold.opacity(0.85))
                .accessibilityHidden(true)
            Text(value)
                .font(.system(.headline, design: .serif, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
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
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(species.displayName), stage \(stage.displayName)")
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
                .accessibilityHidden(true)
            Text("Path: \(path.displayName)")
                .font(.system(.subheadline, design: .serif))
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(
            Capsule().fill(Color.black.opacity(0.4))
                .overlay(Capsule().stroke(Color.ankaGold.opacity(0.6), lineWidth: 1))
        )
        .foregroundStyle(Color.ankaGold)
        .accessibilityElement(children: .combine)
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
            Text("So Far")
                .font(.system(.title3, design: .serif, weight: .semibold))
                .foregroundStyle(Color.ankaGold)
            HStack {
                statTile(label: "Age", value: "\(pet.ageInDays) d")
                statTile(label: "Fed", value: "\(pet.snapshots.count) d")
                statTile(label: "Stage", value: pet.currentStage.displayName)
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
