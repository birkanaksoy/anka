import SwiftUI
import AnkaShared
#if canImport(WatchKit)
import WatchKit
#endif

struct WatchPetView: View {
    let pet: PetState

    @State private var breathePhase: CGFloat = 0
    @State private var crownValue: Double = 0
    @State private var pettingAccumulator: Double = 0
    @State private var lastHapticAt: Date = .distantPast

    var body: some View {
        ZStack {
            background

            VStack(spacing: 4) {
                header
                creature
                    .frame(maxHeight: .infinity)
                footer
            }
            .padding(.horizontal, 6)
        }
        .focusable()
        .digitalCrownRotation(
            $crownValue,
            from: -1000, through: 1000,
            by: 1, sensitivity: .high,
            isContinuous: true,
            isHapticFeedbackEnabled: false
        )
        .onChange(of: crownValue) { oldValue, newValue in
            handleCrown(delta: newValue - oldValue)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever()) {
                breathePhase = 1
            }
        }
    }

    private var background: some View {
        RadialGradient(
            colors: [Color.ankaGoldWatch.opacity(0.25), .black.opacity(0.9)],
            center: .center, startRadius: 0, endRadius: 110
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(spacing: 4) {
            Text(pet.name)
                .font(.system(.caption, design: .serif, weight: .semibold))
                .foregroundStyle(Color.ankaGoldWatch)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(pet.currentStage.displayName)
                .font(.system(.caption2, design: .serif))
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var creature: some View {
        ZStack {
            NourishmentRing(progress: nourishmentProgress)
                .frame(width: 120, height: 120)

            Text(emoji)
                .font(.system(size: 56))
                .scaleEffect(scaleForBreath)
                .shadow(color: Color.ankaGoldWatch.opacity(0.5), radius: 6)
                .accessibilityLabel("\(pet.species.displayName), \(pet.currentStage.displayName)")
                .accessibilityAddTraits(.isButton)
                .accessibilityHint("Double tap to feed")
                .onTapGesture {
                    handleTap()
                }
        }
    }

    private var footer: some View {
        VStack(spacing: 2) {
            Text(pet.currentPath.displayName)
                .font(.system(.caption2, design: .serif, weight: .medium))
                .foregroundStyle(Color.ankaGoldWatch)
            Text("Turn crown to pet")
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(.bottom, 2)
    }

    // MARK: - Derived

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

    private var scaleForBreath: CGFloat {
        // Breathing range 0.92 → 1.08
        let base: CGFloat = 1.0
        let amplitude: CGFloat = 0.08
        let breath = sin(breathePhase * .pi * 2) * amplitude
        return base + breath
    }

    private var nourishmentProgress: Double {
        let n = EvolutionEngine.nourishment(from: pet.snapshots)
        return min(n / 12.0, 1.0)
    }

    // MARK: - Input

    private func handleCrown(delta: Double) {
        pettingAccumulator += abs(delta)
        // Every ~10 ticks of accumulated rotation = a small haptic
        if pettingAccumulator >= 10 {
            pettingAccumulator = 0
            triggerHaptic(.click)
        }
    }

    private func handleTap() {
        triggerHaptic(.notification)
        Task { @MainActor in
            ConnectivityService.shared.send(message: .fed)
        }
    }

    private func triggerHaptic(_ type: WKHapticType) {
        #if canImport(WatchKit)
        // Throttle: at most 1 haptic per 80ms.
        guard Date().timeIntervalSince(lastHapticAt) > 0.08 else { return }
        lastHapticAt = Date()
        WKInterfaceDevice.current().play(type)
        #endif
    }
}

struct NourishmentRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 4)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [Color.ankaGoldWatch.opacity(0.4), Color.ankaGoldWatch],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.6), value: progress)
        }
    }
}
