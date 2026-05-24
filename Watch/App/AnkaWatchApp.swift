import SwiftUI
import AnkaShared

@main
struct AnkaWatchApp: App {
    @State private var pet: PetState?

    init() {
        Task { @MainActor in
            ConnectivityService.shared.activate()
        }
    }

    var body: some Scene {
        WindowGroup {
            WatchRootView(pet: $pet)
                .task {
                    pet = await PetStore.shared.load()
                    ConnectivityService.shared.onPetReceived = { incoming in
                        Task { @MainActor in
                            self.pet = incoming
                            await PetStore.shared.save(incoming)
                        }
                    }
                }
        }
    }
}

struct WatchRootView: View {
    @Binding var pet: PetState?

    var body: some View {
        Group {
            if let pet {
                WatchPetView(pet: pet)
            } else {
                EmptyPetView()
            }
        }
    }
}

struct EmptyPetView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "iphone.circle")
                .font(.largeTitle)
                .foregroundStyle(Color.ankaGoldWatch)
            Text("Open Anka on your iPhone to begin")
                .font(.system(.caption, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

extension Color {
    static let ankaGoldWatch = Color(red: 0.85, green: 0.65, blue: 0.20)
}
