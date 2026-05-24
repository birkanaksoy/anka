import SwiftUI
import AnkaShared

struct SettingsView: View {
    @State private var healthAuthorized = false

    var body: some View {
        ZStack {
            Color.ankaDeepNight.ignoresSafeArea()
            Form {
                Section("Sağlık Verisi") {
                    Button("Apple Health İzni İste") {
                        Task {
                            try? await HealthKitService.shared.requestAuthorization()
                            healthAuthorized = true
                        }
                    }
                    if healthAuthorized {
                        Label("İzin verildi", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }

                Section("Bilgi") {
                    LabeledContent("Versiyon", value: "0.1.0")
                    LabeledContent("Geliştirici", value: "Birkan Aksoy")
                }

                Section("Tehlikeli") {
                    Button("Anka'yı sıfırla", role: .destructive) {
                        Task { await PetStore.shared.clear() }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Ayarlar")
    }
}
