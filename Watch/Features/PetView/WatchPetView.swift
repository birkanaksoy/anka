import SwiftUI
import AnkaShared

struct WatchPetView: View {
    let pet: PetState
    @State private var lastTap: Date?

    var body: some View {
        VStack(spacing: 6) {
            Text(pet.name)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(Color.ankaGoldWatch)
                .lineLimit(1)
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.ankaGoldWatch.opacity(0.4), .clear],
                            center: .center, startRadius: 5, endRadius: 70
                        )
                    )
                Text(emoji)
                    .font(.system(size: 60))
                    .onTapGesture {
                        lastTap = Date()
                        WKInterfaceDevice.current().play(.click)
                    }
            }
            .frame(height: 100)
            Text("\(pet.currentStage.displayName) · \(pet.currentPath.displayName)")
                .font(.system(.caption2, design: .serif))
                .foregroundStyle(.secondary)
        }
    }

    private var emoji: String {
        if pet.currentStage == .egg { return "🥚" }
        switch pet.species {
        case .anka:         return "🔥"
        case .sahmaran:     return "🐍"
        case .hodag:        return "🦌"
        case .karakoncolos: return "❄️"
        case .pirebatak:    return "🦊"
        }
    }
}

#if canImport(WatchKit)
import WatchKit
#endif
