import SwiftUI
import AnkaShared

struct AlbumView: View {
    let records: [HatchRecord]

    var body: some View {
        ZStack {
            Color.ankaDeepNight.ignoresSafeArea()
            if records.isEmpty {
                emptyState
            } else {
                List(records) { record in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(record.species.displayName)
                                .font(.system(.headline, design: .serif))
                                .foregroundStyle(Color.ankaGold)
                            Text(record.path.displayName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(record.evolvedAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color.black.opacity(0.4))
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Hatıra Albümü")
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.closed")
                .font(.system(size: 64))
                .foregroundStyle(Color.ankaGold.opacity(0.5))
            Text("Henüz evrimleşmiş yoldaş yok")
                .font(.system(.title3, design: .serif))
                .foregroundStyle(.white.opacity(0.7))
            Text("Anka'n evrimleştiğinde\nburada yer alacak.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}
