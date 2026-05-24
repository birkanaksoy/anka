import SwiftUI
import AnkaShared

struct SettingsView: View {
    @State private var healthAuthorized = false

    var body: some View {
        ZStack {
            Color.ankaDeepNight.ignoresSafeArea()
            Form {
                Section("Health Data") {
                    Button("Request Apple Health Access") {
                        Task {
                            try? await HealthKitService.shared.requestAuthorization()
                            healthAuthorized = true
                        }
                    }
                    if healthAuthorized {
                        Label("Permission granted", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "0.1.0")
                    LabeledContent("Developer", value: "Birkan Aksoy")
                }

                Section("Danger Zone") {
                    Button("Reset Anka", role: .destructive) {
                        Task { await PetStore.shared.clear() }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
    }
}
