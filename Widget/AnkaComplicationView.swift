import WidgetKit
import SwiftUI
import AnkaShared

struct AnkaComplicationView: View {
    @Environment(\.widgetFamily) private var family
    let entry: AnkaEntry

    var body: some View {
        switch family {
        case .accessoryCircular:    circularView
        case .accessoryCorner:      cornerView
        case .accessoryInline:      inlineView
        case .accessoryRectangular: rectangularView
        default:                    inlineView
        }
    }

    // MARK: - Helpers

    private var symbol: String {
        guard let pet = entry.pet else { return "questionmark" }
        if pet.currentStage == .egg { return "circle.dotted" }
        switch pet.species {
        case .anka:         return "flame.fill"
        case .sahmaran:     return "leaf.fill"
        case .hodag:        return "moon.stars.fill"
        case .karakoncolos: return "snowflake"
        case .pirebatak:    return "hare.fill"
        }
    }

    private var statusLine: String {
        guard let pet = entry.pet else { return "Open Anka" }
        return "\(pet.currentStage.displayName) · \(pet.currentPath.displayName)"
    }

    private var nameLine: String {
        entry.pet?.name ?? "Anka"
    }

    // MARK: - Families

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            Circle()
                .trim(from: 0, to: entry.nourishment)
                .stroke(.tint, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(2)
            Image(systemName: symbol)
                .font(.system(size: 16))
        }
        .widgetAccentable()
    }

    private var cornerView: some View {
        Image(systemName: symbol)
            .font(.system(size: 16))
            .widgetLabel {
                ProgressView(value: entry.nourishment) {
                    Text(nameLine)
                }
            }
    }

    private var inlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
            Text(statusLine)
        }
    }

    private var rectangularView: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .trim(from: 0, to: entry.nourishment)
                    .stroke(.tint, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: symbol)
                    .font(.system(size: 14))
            }
            .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 1) {
                Text(nameLine)
                    .font(.system(.caption, design: .serif, weight: .semibold))
                    .lineLimit(1)
                Text(statusLine)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .widgetAccentable()
    }
}
