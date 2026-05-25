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
                case 1: howItWorks
                case 2: watchPromo
                case 3: speciesPicker
                case 4: namePicker
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

    // MARK: - Step 0 · Welcome

    @ViewBuilder
    private var welcome: some View {
        Spacer()
        VStack(spacing: 16) {
            Text("ANKA")
                .font(.system(size: 64, weight: .bold, design: .serif))
                .foregroundStyle(Color.ankaGold)
            Text("A Wrist Companion")
                .font(.system(.title2, design: .serif))
                .italic()
                .foregroundStyle(.secondary)
        }
        Spacer()
        Text("A mythic creature lives on your Apple Watch.\nYour daily life shapes who it becomes.")
            .multilineTextAlignment(.center)
            .font(.body)
            .foregroundStyle(.white.opacity(0.85))
            .padding(.horizontal)
        Spacer()
        Button(action: { step = 1 }) {
            Text("Begin")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(AnkaPrimaryButtonStyle())
    }

    // MARK: - Step 1 · How it works

    @ViewBuilder
    private var howItWorks: some View {
        VStack(spacing: 6) {
            Spacer().frame(height: 24)
            Text("How It Works")
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .foregroundStyle(Color.ankaGold)
            Text("Just live. Your companion does the rest.")
                .font(.system(.subheadline, design: .serif))
                .italic()
                .foregroundStyle(.secondary)
        }

        Spacer()

        VStack(alignment: .leading, spacing: 20) {
            howRow(icon: "figure.walk",
                   title: "Walk far",
                   subtitle: "Your companion becomes a Wanderer.")
            howRow(icon: "heart.fill",
                   title: "Get your heart pumping",
                   subtitle: "It becomes a Warrior.")
            howRow(icon: "figure.stand",
                   title: "Stand often through the day",
                   subtitle: "It becomes a Sage.")
            howRow(icon: "moon.stars.fill",
                   title: "Sleep deeply",
                   subtitle: "It becomes a Dreamer.")
            howRow(icon: "figure.run",
                   title: "Work out daily",
                   subtitle: "It becomes a Master.")
        }
        .padding(.horizontal)

        Spacer()

        Text("After about two weeks of living your normal life, your companion fully evolves.")
            .font(.footnote)
            .multilineTextAlignment(.center)
            .foregroundStyle(.white.opacity(0.55))
            .padding(.horizontal)

        Button(action: { step = 2 }) {
            Text("Continue")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(AnkaPrimaryButtonStyle())
    }

    private func howRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 36, height: 36)
                .foregroundStyle(Color.ankaGold)
                .background(
                    Circle().fill(Color.ankaGold.opacity(0.12))
                )
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
            }
        }
    }

    // MARK: - Step 2 · Watch promo

    @ViewBuilder
    private var watchPromo: some View {
        Spacer()
        Image(systemName: "applewatch.watchface")
            .font(.system(size: 96))
            .foregroundStyle(Color.ankaGold)
            .accessibilityHidden(true)

        Spacer().frame(height: 16)

        Text("Live on Your Wrist")
            .font(.system(.largeTitle, design: .serif, weight: .bold))
            .foregroundStyle(Color.ankaGold)

        Spacer().frame(height: 12)

        VStack(spacing: 14) {
            promoBullet("Add the Anka complication to your watch face — your companion lives there.")
            promoBullet("Tap the Watch app to greet, feed, or pet with the Digital Crown.")
            promoBullet("The iPhone is the album. The Watch is the companion.")
        }
        .padding(.horizontal, 24)

        Spacer()

        Text("You can add the complication later from your watch face.")
            .font(.footnote)
            .multilineTextAlignment(.center)
            .foregroundStyle(.white.opacity(0.55))
            .padding(.horizontal)

        Button(action: { step = 3 }) {
            Text("Choose Your Companion")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(AnkaPrimaryButtonStyle())
    }

    private func promoBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(Color.ankaGold)
                .accessibilityHidden(true)
            Text(text)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
    }

    // MARK: - Step 3 · Species picker

    @ViewBuilder
    private var speciesPicker: some View {
        Text("Choose Your Companion")
            .font(.system(.largeTitle, design: .serif, weight: .bold))
            .foregroundStyle(Color.ankaGold)
            .padding(.top)
        ScrollView {
            ForEach(CreatureSpecies.allCases, id: \.self) { species in
                SpeciesCard(
                    species: species,
                    isSelected: species == selectedSpecies,
                    locked: false,
                    onTap: { selectedSpecies = species }
                )
            }
        }
        Button(action: { step = 4 }) {
            Text("Continue")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(AnkaPrimaryButtonStyle())
    }

    // MARK: - Step 4 · Name picker

    @ViewBuilder
    private var namePicker: some View {
        Spacer()
        Text("Give It a Name")
            .font(.system(.largeTitle, design: .serif, weight: .bold))
            .foregroundStyle(Color.ankaGold)
        Text(selectedSpecies.displayName)
            .font(.system(.title3, design: .serif))
            .foregroundStyle(.secondary)
        TextField("Name", text: $name)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 40)
            .padding(.top)
        Spacer()
        Text("After hatching, Anka will grant access to Apple Health to start growing.")
            .font(.footnote)
            .multilineTextAlignment(.center)
            .foregroundStyle(.white.opacity(0.55))
            .padding(.horizontal)
        Button {
            Task {
                let finalName = name.trimmingCharacters(in: .whitespaces).isEmpty
                    ? selectedSpecies.displayName : name
                try? await HealthKitService.shared.requestAuthorization()
                await onComplete(selectedSpecies, finalName)
            }
        } label: {
            Text("Hatch the Egg")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(AnkaPrimaryButtonStyle())
    }
}

struct SpeciesCard: View {
    let species: CreatureSpecies
    let isSelected: Bool
    let locked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                CreatureArt(species: species, stage: .adult)
                    .frame(width: 56, height: 56)
                    .accessibilityHidden(true)

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
                        .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(species.displayName)
            .accessibilityValue(isSelected ? "Selected" : "Not selected")
            .accessibilityHint(species.loreShort)
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
