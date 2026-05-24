import SwiftUI
import AnkaShared

struct PaywallView: View {
    @StateObject private var store = StoreService.shared
    @Environment(\.dismiss) private var dismiss

    let dismissible: Bool

    var body: some View {
        ZStack {
            background

            VStack(spacing: 24) {
                if dismissible {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(.trailing, 8)
                    }
                }

                Spacer(minLength: 0)

                Text("ANKA PREMIUM")
                    .font(.system(.title2, design: .serif, weight: .bold))
                    .foregroundStyle(Color.ankaGold)
                    .tracking(2)

                Text("One purchase. Five creatures.\nEvery evolution path. Forever.")
                    .multilineTextAlignment(.center)
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    benefit("Hatch all 5 mythological creatures")
                    benefit("Explore all 5 evolution paths")
                    benefit("Watch complications & widgets")
                    benefit("No ads. No subscriptions. Forever.")
                }
                .padding(.horizontal, 32)

                Spacer(minLength: 0)

                VStack(spacing: 12) {
                    Button {
                        Task { await store.purchase() }
                    } label: {
                        Group {
                            if store.isPurchasing {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Text(buyLabel)
                                    .font(.system(.title3, design: .serif, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 32)
                    }
                    .buttonStyle(AnkaPrimaryButtonStyle())
                    .disabled(store.isPurchasing)

                    Button("Restore Purchase") {
                        Task { await store.restore() }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))

                    if let error = store.purchaseError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .task { await store.refresh() }
        .onChange(of: store.isPremium) { _, premium in
            if premium { dismiss() }
        }
    }

    private var buyLabel: String {
        if let price = store.product?.displayPrice {
            return "Unlock for \(price)"
        }
        return "Unlock Anka Premium"
    }

    private var background: some View {
        LinearGradient(
            colors: [Color(red: 0.18, green: 0.10, blue: 0.06),
                     Color(red: 0.05, green: 0.03, blue: 0.04)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private func benefit(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundStyle(Color.ankaGold)
                .accessibilityHidden(true)
            Text(text)
                .font(.system(.body, design: .serif))
                .foregroundStyle(.white)
            Spacer(minLength: 0)
        }
    }
}
