import SwiftUI

/// Programmatic, scale-free art for every creature × stage combination.
///
/// All variants share:
/// - A soft radial halo behind the silhouette
/// - A consistent silhouette anchor (centered, 70% canvas height)
/// - A signature accent color per creature
///
/// Stage drives **complexity**, not silhouette swap:
/// - `.egg`    — shared egg, tinted by creature palette
/// - `.baby`   — minimal blob, eyes only
/// - `.young`  — half features
/// - `.adult`  — full silhouette
/// - `.evolved`— full silhouette + glow rays + signature ornament
public struct CreatureArt: View {
    public let species: CreatureSpecies
    public let stage: LifeStage

    public init(species: CreatureSpecies, stage: LifeStage) {
        self.species = species
        self.stage = stage
    }

    public var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                Halo(color: palette.glow, stage: stage)
                if stage == .egg {
                    Egg(tint: palette.accent)
                        .frame(width: size * 0.55, height: size * 0.7)
                } else {
                    silhouette
                        .frame(width: size * 0.85, height: size * 0.85)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    @ViewBuilder
    private var silhouette: some View {
        switch species {
        case .anka:         AnkaSilhouette(stage: stage, palette: palette)
        case .sahmaran:     SahmaranSilhouette(stage: stage, palette: palette)
        case .hodag:        HodagSilhouette(stage: stage, palette: palette)
        case .karakoncolos: KarakoncolosSilhouette(stage: stage, palette: palette)
        case .pirebatak:    PirebatakSilhouette(stage: stage, palette: palette)
        }
    }

    var palette: Palette {
        Palette.for(species)
    }
}

// MARK: - Palette

struct Palette {
    let accent: Color    // main body fill
    let outline: Color   // line + detail
    let glow: Color      // halo + evolved aura
    let highlight: Color // facial / accessory pop

    static func `for`(_ species: CreatureSpecies) -> Palette {
        switch species {
        case .anka:
            return Palette(
                accent:    Color(red: 0.95, green: 0.42, blue: 0.18),
                outline:   Color(red: 0.55, green: 0.18, blue: 0.05),
                glow:      Color(red: 1.0,  green: 0.65, blue: 0.20),
                highlight: Color(red: 1.0,  green: 0.90, blue: 0.55)
            )
        case .sahmaran:
            return Palette(
                accent:    Color(red: 0.20, green: 0.62, blue: 0.42),
                outline:   Color(red: 0.06, green: 0.28, blue: 0.18),
                glow:      Color(red: 0.55, green: 0.85, blue: 0.55),
                highlight: Color(red: 0.95, green: 0.80, blue: 0.30)  // her crown
            )
        case .hodag:
            return Palette(
                accent:    Color(red: 0.38, green: 0.25, blue: 0.55),
                outline:   Color(red: 0.10, green: 0.05, blue: 0.20),
                glow:      Color(red: 0.55, green: 0.40, blue: 0.85),
                highlight: Color(red: 0.85, green: 0.95, blue: 1.0)
            )
        case .karakoncolos:
            return Palette(
                accent:    Color(red: 0.78, green: 0.85, blue: 0.92),
                outline:   Color(red: 0.30, green: 0.40, blue: 0.55),
                glow:      Color(red: 0.65, green: 0.85, blue: 1.0),
                highlight: Color(red: 0.30, green: 0.20, blue: 0.15)  // dark eyes
            )
        case .pirebatak:
            return Palette(
                accent:    Color(red: 0.85, green: 0.50, blue: 0.25),
                outline:   Color(red: 0.40, green: 0.20, blue: 0.08),
                glow:      Color(red: 0.95, green: 0.70, blue: 0.40),
                highlight: Color(red: 0.98, green: 0.95, blue: 0.85)
            )
        }
    }
}

// MARK: - Common pieces

struct Halo: View {
    let color: Color
    let stage: LifeStage

    var body: some View {
        let intensity = haloIntensity
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(intensity), .clear],
                    center: .center,
                    startRadius: 4,
                    endRadius: 200
                )
            )
    }

    private var haloIntensity: Double {
        switch stage {
        case .egg:     return 0.28
        case .baby:    return 0.30
        case .young:   return 0.36
        case .adult:   return 0.42
        case .evolved: return 0.55
        }
    }
}

struct Egg: View {
    let tint: Color

    var body: some View {
        ZStack {
            EggShape()
                .fill(
                    LinearGradient(
                        colors: [
                            tint.opacity(0.95),
                            tint.opacity(0.55)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            EggShape()
                .stroke(tint.opacity(0.85), lineWidth: 2)
            // Subtle highlight
            Ellipse()
                .fill(Color.white.opacity(0.25))
                .frame(width: 12, height: 24)
                .offset(x: -8, y: -20)
        }
    }
}

struct EggShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.midX - w * 0.65, y: h * 0.45),
            control2: CGPoint(x: rect.midX - w * 0.55, y: rect.maxY)
        )
        p.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.midX + w * 0.55, y: rect.maxY),
            control2: CGPoint(x: rect.midX + w * 0.65, y: h * 0.45)
        )
        return p
    }
}

struct EyePair: View {
    let color: Color
    let openness: CGFloat  // 0 = closed, 1 = round
    let spread: CGFloat    // distance multiplier

    var body: some View {
        HStack(spacing: 14 * spread) {
            Ellipse()
                .fill(color)
                .frame(width: 5, height: 5 * openness + 1)
            Ellipse()
                .fill(color)
                .frame(width: 5, height: 5 * openness + 1)
        }
    }
}

// MARK: - Anka (Phoenix)

struct AnkaSilhouette: View {
    let stage: LifeStage
    let palette: Palette

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                if stage >= .adult {
                    Flame(palette: palette)
                        .frame(width: s * 0.9, height: s * 0.6)
                        .offset(y: s * 0.15)
                }
                Bird(stage: stage, palette: palette)
                    .frame(width: s * bodyScale, height: s * bodyScale)
                if stage == .evolved {
                    GlowRays(color: palette.glow)
                        .frame(width: s, height: s)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var bodyScale: CGFloat {
        switch stage {
        case .baby: return 0.5
        case .young: return 0.65
        case .adult: return 0.78
        case .evolved: return 0.85
        default: return 0.5
        }
    }

    struct Bird: View {
        let stage: LifeStage
        let palette: Palette
        var body: some View {
            ZStack {
                AnkaBodyShape()
                    .fill(
                        LinearGradient(
                            colors: [palette.highlight, palette.accent, palette.outline],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                AnkaBodyShape()
                    .stroke(palette.outline, lineWidth: 2)
                EyePair(color: palette.outline, openness: 0.8, spread: 0.9)
                    .offset(y: -8)
            }
        }
    }

    struct Flame: View {
        let palette: Palette
        var body: some View {
            FlameShape()
                .fill(
                    LinearGradient(
                        colors: [palette.highlight, palette.accent.opacity(0)],
                        startPoint: .bottom, endPoint: .top
                    )
                )
                .blur(radius: 4)
        }
    }
}

struct AnkaBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        // Head
        p.addEllipse(in: CGRect(x: rect.midX - w*0.22, y: rect.minY, width: w*0.44, height: h*0.42))
        // Beak
        p.move(to: CGPoint(x: rect.midX, y: h*0.18))
        p.addLine(to: CGPoint(x: rect.midX - w*0.05, y: h*0.30))
        p.addLine(to: CGPoint(x: rect.midX + w*0.05, y: h*0.30))
        p.closeSubpath()
        // Body teardrop
        p.move(to: CGPoint(x: rect.midX, y: h*0.38))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                       control: CGPoint(x: rect.minX, y: h*0.85))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: h*0.38),
                       control: CGPoint(x: rect.maxX, y: h*0.85))
        // Wings (curved arcs)
        p.move(to: CGPoint(x: rect.midX - w*0.10, y: h*0.45))
        p.addQuadCurve(to: CGPoint(x: rect.midX - w*0.42, y: h*0.62),
                       control: CGPoint(x: rect.midX - w*0.50, y: h*0.40))
        p.addQuadCurve(to: CGPoint(x: rect.midX - w*0.10, y: h*0.60),
                       control: CGPoint(x: rect.midX - w*0.28, y: h*0.75))
        p.move(to: CGPoint(x: rect.midX + w*0.10, y: h*0.45))
        p.addQuadCurve(to: CGPoint(x: rect.midX + w*0.42, y: h*0.62),
                       control: CGPoint(x: rect.midX + w*0.50, y: h*0.40))
        p.addQuadCurve(to: CGPoint(x: rect.midX + w*0.10, y: h*0.60),
                       control: CGPoint(x: rect.midX + w*0.28, y: h*0.75))
        return p
    }
}

struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.midX - w*0.5, y: rect.maxY*0.6),
            control2: CGPoint(x: rect.midX - w*0.15, y: rect.maxY*0.25)
        )
        p.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.midX + w*0.15, y: rect.maxY*0.25),
            control2: CGPoint(x: rect.midX + w*0.5, y: rect.maxY*0.6)
        )
        return p
    }
}

// MARK: - Şahmaran (serpent-queen)

struct SahmaranSilhouette: View {
    let stage: LifeStage
    let palette: Palette

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                SerpentShape()
                    .stroke(
                        palette.accent,
                        style: StrokeStyle(lineWidth: s * 0.10, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: s * 0.75, height: s * 0.75)
                SerpentShape()
                    .stroke(palette.outline, lineWidth: 2)
                    .frame(width: s * 0.75, height: s * 0.75)

                // Head at the top of the curve
                ZStack {
                    Circle()
                        .fill(palette.accent)
                        .frame(width: s * 0.22, height: s * 0.22)
                    Circle()
                        .stroke(palette.outline, lineWidth: 2)
                        .frame(width: s * 0.22, height: s * 0.22)
                    if stage >= .adult {
                        Crown(color: palette.highlight)
                            .frame(width: s * 0.18, height: s * 0.10)
                            .offset(y: -s * 0.16)
                    }
                    EyePair(color: palette.outline, openness: 0.7, spread: 0.6)
                        .offset(y: -2)
                }
                .offset(y: -s * 0.28)

                if stage == .evolved {
                    GlowRays(color: palette.glow)
                        .frame(width: s, height: s)
                }
            }
        }
    }

    struct Crown: View {
        let color: Color
        var body: some View {
            CrownShape()
                .fill(color)
                .overlay(CrownShape().stroke(color.opacity(0.6), lineWidth: 1))
        }
    }
}

struct SerpentShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        // Wavy S from top-center to bottom-center
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addCurve(
            to: CGPoint(x: rect.midX, y: h * 0.5),
            control1: CGPoint(x: rect.midX + w * 0.4, y: h * 0.15),
            control2: CGPoint(x: rect.midX - w * 0.4, y: h * 0.35)
        )
        p.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.midX + w * 0.4, y: h * 0.65),
            control2: CGPoint(x: rect.midX - w * 0.4, y: h * 0.85)
        )
        return p
    }
}

struct CrownShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.width * 0.25, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.width * 0.75, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Hodağ (forest spirit)

struct HodagSilhouette: View {
    let stage: LifeStage
    let palette: Palette

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                if stage >= .young {
                    AntlerShape()
                        .stroke(
                            palette.outline,
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: s * 0.6, height: s * 0.35)
                        .offset(y: -s * 0.30)
                }
                // Body
                HodagBody()
                    .fill(palette.accent)
                    .overlay(HodagBody().stroke(palette.outline, lineWidth: 2))
                    .frame(width: s * 0.7, height: s * 0.55)
                    .offset(y: s * 0.10)
                // Glowing eyes
                HStack(spacing: 14) {
                    Circle()
                        .fill(palette.highlight)
                        .frame(width: 6, height: 6)
                        .shadow(color: palette.highlight, radius: stage == .evolved ? 6 : 2)
                    Circle()
                        .fill(palette.highlight)
                        .frame(width: 6, height: 6)
                        .shadow(color: palette.highlight, radius: stage == .evolved ? 6 : 2)
                }
                .offset(y: -s * 0.05)

                if stage == .evolved {
                    GlowRays(color: palette.glow)
                        .frame(width: s, height: s)
                }
            }
        }
    }
}

struct HodagBody: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.minY - h * 0.15)
        )
        p.addLine(to: CGPoint(x: rect.maxX - w*0.10, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + w*0.10, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct AntlerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        // Left antler
        p.move(to: CGPoint(x: rect.midX - w*0.15, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.midX - w*0.25, y: h*0.4))
        p.addLine(to: CGPoint(x: rect.midX - w*0.45, y: rect.minY))
        p.move(to: CGPoint(x: rect.midX - w*0.25, y: h*0.4))
        p.addLine(to: CGPoint(x: rect.midX - w*0.10, y: h*0.1))
        // Right antler
        p.move(to: CGPoint(x: rect.midX + w*0.15, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.midX + w*0.25, y: h*0.4))
        p.addLine(to: CGPoint(x: rect.midX + w*0.45, y: rect.minY))
        p.move(to: CGPoint(x: rect.midX + w*0.25, y: h*0.4))
        p.addLine(to: CGPoint(x: rect.midX + w*0.10, y: h*0.1))
        return p
    }
}

// MARK: - Karakoncolos (winter spirit)

struct KarakoncolosSilhouette: View {
    let stage: LifeStage
    let palette: Palette

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                KaraBody()
                    .fill(palette.accent)
                    .overlay(KaraBody().stroke(palette.outline, lineWidth: 2))
                    .frame(width: s * 0.7, height: s * 0.8)
                // Eyes (dark, beady)
                EyePair(color: palette.highlight, openness: 0.5, spread: 0.7)
                    .offset(y: -s * 0.15)
                // Frost particles
                if stage >= .young {
                    ForEach(0..<6, id: \.self) { i in
                        let angle = Double(i) * .pi / 3
                        let r = s * 0.42
                        FrostFlake()
                            .frame(width: 6, height: 6)
                            .foregroundStyle(palette.glow)
                            .offset(
                                x: CGFloat(cos(angle)) * r,
                                y: CGFloat(sin(angle)) * r
                            )
                    }
                }
                if stage == .evolved {
                    GlowRays(color: palette.glow)
                        .frame(width: s, height: s)
                }
            }
        }
    }
}

struct KaraBody: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        // Triangular furry form: rounded top, broad base
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addQuadCurve(
            to: CGPoint(x: rect.minX + w*0.05, y: rect.maxY),
            control: CGPoint(x: rect.minX - w*0.1, y: h*0.5)
        )
        // Furry zigzag base
        let steps = 8
        for i in 1...steps {
            let x = rect.minX + w * CGFloat(i) / CGFloat(steps)
            let y = rect.maxY - (i % 2 == 0 ? 0 : h*0.04)
            p.addLine(to: CGPoint(x: x, y: y))
        }
        p.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.maxX + w*0.1, y: h*0.5)
        )
        return p
    }
}

struct FrostFlake: View {
    var body: some View {
        ZStack {
            Capsule().frame(width: 1, height: 8)
            Capsule().frame(width: 1, height: 8).rotationEffect(.degrees(60))
            Capsule().frame(width: 1, height: 8).rotationEffect(.degrees(-60))
        }
    }
}

// MARK: - Pirebatak (swift helper)

struct PirebatakSilhouette: View {
    let stage: LifeStage
    let palette: Palette

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                PireBody()
                    .fill(palette.accent)
                    .overlay(PireBody().stroke(palette.outline, lineWidth: 2))
                    .frame(width: s * 0.8, height: s * 0.6)
                    .offset(y: s * 0.05)
                if stage >= .young {
                    // Two pointed ears
                    Ear(palette: palette)
                        .frame(width: 16, height: 24)
                        .offset(x: -s * 0.20, y: -s * 0.28)
                    Ear(palette: palette)
                        .frame(width: 16, height: 24)
                        .offset(x: s * 0.20, y: -s * 0.28)
                }
                EyePair(color: palette.outline, openness: 1.0, spread: 1.1)
                    .offset(y: -s * 0.05)
                if stage == .evolved {
                    GlowRays(color: palette.glow)
                        .frame(width: s, height: s)
                }
            }
        }
    }

    struct Ear: View {
        let palette: Palette
        var body: some View {
            Triangle()
                .fill(palette.accent)
                .overlay(Triangle().stroke(palette.outline, lineWidth: 2))
        }
    }
}

struct PireBody: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        // Rounded body with tail tip on the right
        p.move(to: CGPoint(x: rect.minX + w*0.15, y: rect.maxY))
        p.addQuadCurve(
            to: CGPoint(x: rect.minX, y: h*0.4),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        p.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.minX + w*0.1, y: rect.minY)
        )
        p.addQuadCurve(
            to: CGPoint(x: rect.maxX - w*0.05, y: h*0.5),
            control: CGPoint(x: rect.maxX, y: h*0.1)
        )
        // Tail flick
        p.addLine(to: CGPoint(x: rect.maxX, y: h*0.65))
        p.addLine(to: CGPoint(x: rect.maxX - w*0.05, y: h*0.75))
        p.addLine(to: CGPoint(x: rect.maxX - w*0.10, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Shared glow

struct GlowRays: View {
    let color: Color

    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.7), .clear],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 3, height: 60)
                    .offset(y: -80)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
        }
        .blendMode(.screen)
        .opacity(0.7)
    }
}

#Preview("All creatures, all stages") {
    let species: [CreatureSpecies] = [.anka, .sahmaran, .hodag, .karakoncolos, .pirebatak]
    let stages: [LifeStage] = [.egg, .baby, .young, .adult, .evolved]
    return ScrollView {
        VStack {
            ForEach(species, id: \.self) { sp in
                HStack {
                    ForEach(stages, id: \.self) { st in
                        CreatureArt(species: sp, stage: st)
                            .frame(width: 80, height: 80)
                    }
                }
            }
        }
        .padding()
    }
    .background(Color.black)
}
