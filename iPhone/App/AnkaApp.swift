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
        if let pet = result.pet {
            await NotificationService.shared.scheduleDailyReminderIfNeeded(pet: pet)
        }
        if let evolved = result.evolved {
            await NotificationService.shared.scheduleEvolutionCelebration(record: evolved)
        }
    }
}

struct RootView: View {
    @Binding var pet: PetState?
    @Binding var todaySnapshot: HealthSnapshot?
    @Binding var newlyEvolved: HatchRecord?
    @State private var showFirstHatchTutorial = false
    @AppStorage("hasSeenFirstHatchTutorial") private var hasSeenFirstHatchTutorial = false

    var body: some View {
        Group {
            if let pet {
                HomeView(pet: pet, todaySnapshot: todaySnapshot)
                    .sheet(item: $newlyEvolved) { record in
                        EvolutionCelebrationView(record: record)
                    }
                    .sheet(isPresented: $showFirstHatchTutorial) {
                        FirstHatchTutorial(species: pet.species) {
                            hasSeenFirstHatchTutorial = true
                            showFirstHatchTutorial = false
                        }
                    }
            } else {
                OnboardingView { species, name in
                    let newPet = PetState(species: species, name: name)
                    await PetStore.shared.save(newPet)
                    pet = newPet
                    if !hasSeenFirstHatchTutorial {
                        showFirstHatchTutorial = true
                    }
                }
            }
        }
    }
}

struct FirstHatchTutorial: View {
    let species: CreatureSpecies
    let onDone: () -> Void

    var body: some View {
        ZStack {
            Color.ankaDeepNight.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 12)

                    CreatureArt(species: species, stage: .egg)
                        .frame(width: 140, height: 140)

                    Text("Your egg is ready")
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .foregroundStyle(Color.ankaGold)
                    Text("Here's what happens next.")
                        .font(.system(.subheadline, design: .serif))
                        .italic()
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 18) {
                        tutorialRow(
                            number: "1",
                            title: "Live your day",
                            body: "Walk, sleep, move. The app reads your activity from Apple Health automatically. You don't need to open it every day."
                        )
                        tutorialRow(
                            number: "2",
                            title: "Add the watch face complication",
                            body: "Long-press your Apple Watch face → Edit → Complications → choose Anka. Now your companion is always visible."
                        )
                        tutorialRow(
                            number: "3",
                            title: "Tap your Watch to greet",
                            body: "Open the Anka app on your Watch any time. Tap to feed. Turn the Digital Crown to pet — you'll feel the haptic reply."
                        )
                        tutorialRow(
                            number: "4",
                            title: "Evolution takes about two weeks",
                            body: "Around day 14 your companion fully evolves into one of five forms — based on how you actually lived."
                        )
                        tutorialRow(
                            number: "5",
                            title: "Collect all paths",
                            body: "After evolution, your companion is archived in the Album. A new egg of your choice takes its place. Five creatures × five paths = 25 forms to collect."
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 12)

                    Button(action: onDone) {
                        Text("Begin")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(AnkaPrimaryButtonStyle())
                    .padding(.horizontal)

                    Spacer().frame(height: 24)
                }
                .padding(.top)
            }
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(true)
    }

    private func tutorialRow(number: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number)
                .font(.system(.title3, design: .serif, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.ankaGold))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(Color.ankaGold)
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
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

