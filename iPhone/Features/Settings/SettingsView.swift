import SwiftUI
import AnkaShared

struct SettingsView: View {
    @State private var healthAuthorized = false
    @State private var notificationsAuthorized = false

    var body: some View {
        ZStack {
            Color.ankaDeepNight.ignoresSafeArea()
            Form {
                Section("Permissions") {
                    Button("Request Apple Health Access") {
                        Task {
                            try? await HealthKitService.shared.requestAuthorization()
                            healthAuthorized = true
                        }
                    }
                    if healthAuthorized {
                        Label("Health granted", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    Button("Request Notification Access") {
                        Task {
                            notificationsAuthorized = await NotificationService.shared.requestAuthorization()
                        }
                    }
                    if notificationsAuthorized {
                        Label("Notifications granted", systemImage: "checkmark.circle.fill")
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
            .task {
                notificationsAuthorized = await NotificationService.shared.authorizationStatus()
            }
        }
        .navigationTitle("Settings")
    }
}
