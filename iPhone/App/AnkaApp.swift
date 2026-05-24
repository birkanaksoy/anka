import SwiftUI
import WidgetKit
import AnkaShared

@main
struct AnkaApp: App {
    @State private var pet: PetState?
    @State private var todaySnapshot: HealthSnapshot?
    @State private var newlyEvolved: HatchRecord?

    init() {
        BackgroundRefresh.register()
        Task { @MainActor in
            ConnectivityService.shared.activate()
            ConnectivityService.shared.onMessage = { msg in
                Task { @MainActor in
                    if msg == .refreshNow {
                        _ = await DailyPipeline().run()
                    }
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                pet: $pet,
                todaySnapshot: $todaySnapshot,
                newlyEvolved: $newlyEvolved
            )
            .task {
                await loadPet()
                await runPipeline()
            }
            .onChange(of: pet?.id) { _, _ in
                BackgroundRefresh.schedule()
            }
        }
    }

    private func loadPet() async {
        pet = await PetStore.shared.load()
    }

    private func runPipeline() async {
        guard pet != nil else { return }
        let result = await DailyPipeline().run()
        await MainActor.run {
            self.todaySnapshot = result.snapshot
            self.pet = result.pet
            if let evolved = result.evolved {
                self.newlyEvolved = evolved
            }
            if let pet = result.pet {
                ConnectivityService.shared.push(pet: pet)
            }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

struct RootView: View {
    @Binding var pet: PetState?
    @Binding var todaySnapshot: HealthSnapshot?
    @Binding var newlyEvolved: HatchRecord?

    var body: some View {
        Group {
            if let pet {
                HomeView(pet: pet, todaySnapshot: todaySnapshot)
                    .sheet(item: $newlyEvolved) { record in
                        EvolutionCelebrationView(record: record)
                    }
            } else {
                OnboardingView { species, name in
                    let newPet = PetState(species: species, name: name)
                    await PetStore.shared.save(newPet)
                    pet = newPet
                }
            }
        }
    }
}

struct EvolutionCelebrationView: View {
    let record: HatchRecord

    var body: some View {
        ZStack {
            Color.ankaDeepNight.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Evolved!")
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundStyle(Color.ankaGold)
                Text(record.species.displayName)
                    .font(.system(.title2, design: .serif))
                    .foregroundStyle(.white)
                Text("Path of the \(record.path.displayName)")
                    .font(.system(.title3, design: .serif))
                    .italic()
                    .foregroundStyle(.secondary)
                Text("A new egg awaits.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top)
            }
            .padding()
        }
        .presentationDetents([.medium])
    }
}

