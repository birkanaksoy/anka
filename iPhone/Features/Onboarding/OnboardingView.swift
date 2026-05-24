import SwiftUI
import AnkaShared

struct OnboardingView: View {
    let onComplete: (CreatureSpecies, String) async -> Void

    @State private var step = 0
    @State private var selectedSpecies: CreatureSpecies = .anka
    @State private var name: String = ""

    var body: some View {
        ZStack {
            background
            VStack {
                switch step {
                case 0: welcome
                case 1: speciesPicker
                case 2: namePicker
                default: EmptyView()
                }
            }
            .padding()
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [Color(red: 0.12, green: 0.08, blue: 0.10),
                     Color(red: 0.20, green: 0.13, blue: 0.08)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var welcome: some View {
        Spacer()
        VStack(spacing: 16) {
            Text("ANKA")
                .font(.system(size: 64, weight: .bold, design: .serif))
                .foregroundStyle(Color.ankaGold)
            Text("Bileğinde bir yoldaş")
                .font(.system(.title2, design: .serif))
                .italic()
                .foregroundStyle(.secondary)
        }
        Spacer()
        Text("Adımlarınla, kalp atışınla, uykunla beslenecek.\nHangi mitolojik canlı seninle yola çıkacak?")
            .multilineTextAlignment(.center)
            .font(.body)
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal)
        Spacer()
        Button(action: { step = 1 }) {
            Text("Başla")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(AnkaPrimaryButtonStyle())
    }

    @ViewBuilder
    private var speciesPicker: some View {
        Text("Yoldaşını Seç")
            .font(.system(.largeTitle, design: .serif, weight: .bold))
            .foregroundStyle(Color.ankaGold)
            .padding(.top)
        ScrollView {
            ForEach(CreatureSpecies.allCases, id: \.self) { species in
                SpeciesCard(
                    species: species,
                    isSelected: species == selectedSpecies,
                    onTap: { selectedSpecies = species }
                )
            }
        }
        Button(action: { step = 2 }) {
            Text("Devam")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(AnkaPrimaryButtonStyle())
    }

    @ViewBuilder
    private var namePicker: some View {
        Spacer()
        Text("Bir İsim Ver")
            .font(.system(.largeTitle, design: .serif, weight: .bold))
            .foregroundStyle(Color.ankaGold)
        Text(selectedSpecies.displayName)
            .font(.system(.title3, design: .serif))
            .foregroundStyle(.secondary)
        TextField("İsim", text: $name)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 40)
            .padding(.top)
        Spacer()
        Button {
            Task {
                let finalName = name.trimmingCharacters(in: .whitespaces).isEmpty
                    ? selectedSpecies.displayName : name
                await onComplete(selectedSpecies, finalName)
            }
        } label: {
            Text("Yumurtayı Aç")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(AnkaPrimaryButtonStyle())
    }
}

struct SpeciesCard: View {
    let species: CreatureSpecies
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(species.displayName)
                        .font(.system(.title3, design: .serif, weight: .semibold))
                        .foregroundStyle(Color.ankaGold)
                    Text(species.loreShort)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.ankaGold)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.ankaGold : Color.ankaGold.opacity(0.3), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}

struct AnkaPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.title3, design: .serif, weight: .semibold))
            .foregroundStyle(.black)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.ankaGold)
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            )
    }
}

extension Color {
    static let ankaGold = Color(red: 0.85, green: 0.65, blue: 0.20)
    static let ankaCrimson = Color(red: 0.65, green: 0.15, blue: 0.15)
    static let ankaDeepNight = Color(red: 0.10, green: 0.07, blue: 0.09)
}
