import SwiftUI
import AnkaShared

@main
struct AnkaApp: App {
    @State private var pet: PetState?

    var body: some Scene {
        WindowGroup {
            RootView(pet: $pet)
                .task { await loadPet() }
        }
    }

    private func loadPet() async {
        pet = await PetStore.shared.load()
    }
}

struct RootView: View {
    @Binding var pet: PetState?

    var body: some View {
        if let pet {
            HomeView(pet: pet)
        } else {
            OnboardingView { species, name in
                let newPet = PetState(species: species, name: name)
                await PetStore.shared.save(newPet)
                pet = newPet
            }
        }
    }
}
