import SwiftUI
import AnkaShared

@main
struct AnkaWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchRootView()
        }
    }
}

struct WatchRootView: View {
    @State private var pet: PetState?

    var body: some View {
        Group {
            if let pet {
                WatchPetView(pet: pet)
            } else {
                EmptyPetView()
            }
        }
        .task { pet = await PetStore.shared.load() }
    }
}

struct EmptyPetView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "iphone.circle")
                .font(.largeTitle)
                .foregroundStyle(Color.ankaGoldWatch)
            Text("iPhone'da Anka'nı oluştur")
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
