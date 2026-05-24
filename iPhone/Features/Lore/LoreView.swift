import SwiftUI
import AnkaShared

struct LoreView: View {
    var body: some View {
        ZStack {
            Color.ankaDeepNight.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(CreatureSpecies.allCases, id: \.self) { species in
                        LoreCard(species: species)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Efsane Kitabı")
    }
}

struct LoreCard: View {
    let species: CreatureSpecies

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(species.displayName)
                .font(.system(.title2, design: .serif, weight: .bold))
                .foregroundStyle(Color.ankaGold)
            Text(species.loreShort)
                .font(.body)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
}
