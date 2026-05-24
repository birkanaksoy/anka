import WidgetKit
import SwiftUI
import AnkaShared

@main
struct AnkaWidgetBundle: WidgetBundle {
    var body: some Widget {
        AnkaComplication()
    }
}

struct AnkaComplication: Widget {
    let kind = "AnkaComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AnkaTimelineProvider()) { entry in
            AnkaComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Anka")
        .description("See your companion at a glance.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}
