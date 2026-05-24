import Foundation
import StoreKit

/// Owns the StoreKit 2 lifecycle for Anka Premium.
///
/// Single non-consumable product `anka.premium.lifetime` unlocks:
/// - All 5 creatures
/// - All evolution paths
/// - All complications
/// - Lifetime updates
///
/// Free tier allows the player to hatch one Anka creature only.
@MainActor
public final class StoreService: ObservableObject {
    public static let shared = StoreService()

    public nonisolated static let productID = "com.birkanaksoy.anka.premium.lifetime"

    @Published public private(set) var product: Product?
    @Published public private(set) var isPremium: Bool = false
    @Published public private(set) var isPurchasing: Bool = false
    @Published public private(set) var purchaseError: String?

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = listenForTransactions()
        Task { await refresh() }
    }

    // MARK: - Public API

    public func refresh() async {
        await loadProduct()
        await refreshEntitlements()
    }

    public func purchase() async {
        guard let product else { return }
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try verify(verification)
                isPremium = true
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Payment is pending approval."
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    public func restore() async {
        do {
            try await AppStore.sync()
        } catch {
            purchaseError = error.localizedDescription
        }
        await refreshEntitlements()
    }

    // MARK: - Internal

    private func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.productID])
            self.product = products.first
        } catch {
            // Fail silently; the paywall will show a fallback price label.
        }
    }

    private func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                isPremium = true
                return
            }
        }
        isPremium = false
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await update in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = update,
                   transaction.productID == Self.productID {
                    await transaction.finish()
                    await MainActor.run { self.isPremium = true }
                }
            }
        }
    }

    private func verify<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value): return value
        case .unverified(_, let error): throw error
        }
    }
}
