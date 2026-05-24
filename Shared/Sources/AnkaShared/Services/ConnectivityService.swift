import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

/// Bridges PetState updates between iPhone and Apple Watch.
/// - Uses WCSession's `updateApplicationContext` for the latest pet snapshot
///   (delivered eventually even when the counterpart is asleep).
/// - Uses `sendMessage` for "live" interactions when both apps are awake.
@MainActor
public final class ConnectivityService: NSObject {
    public static let shared = ConnectivityService()

    /// Callback invoked when a new PetState is received from the counterpart.
    public var onPetReceived: (@Sendable (PetState) -> Void)?

    /// Callback invoked when a live message ("nudge", "fed", etc.) arrives.
    public var onMessage: (@Sendable (ConnectivityMessage) -> Void)?

    private override init() { super.init() }

    public func activate() {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        #endif
    }

    /// Send the latest PetState as the application context. Cheap and reliable —
    /// iOS coalesces these into a single delivery.
    public func push(pet: PetState) {
        #if canImport(WatchConnectivity)
        guard WCSession.default.activationState == .activated else { return }
        do {
            let data = try JSONEncoder().encode(pet)
            try WCSession.default.updateApplicationContext(["pet": data])
        } catch {
            // Silently ignore — counterpart is unreachable or context size exceeded.
        }
        #endif
    }

    /// Send a small live message. Best-effort: drops if counterpart is unreachable.
    public func send(message: ConnectivityMessage) {
        #if canImport(WatchConnectivity)
        guard WCSession.default.activationState == .activated,
              WCSession.default.isReachable else { return }
        if let data = try? JSONEncoder().encode(message) {
            WCSession.default.sendMessage(["msg": data], replyHandler: nil, errorHandler: nil)
        }
        #endif
    }
}

public enum ConnectivityMessage: Codable, Sendable {
    case nudge       // brief haptic prompt
    case fed         // user fed pet on Watch
    case refreshNow  // counterpart asks for a refresh
}

#if canImport(WatchConnectivity)
extension ConnectivityService: WCSessionDelegate {
    nonisolated public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    #if os(iOS)
    nonisolated public func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated public func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate so a different paired watch can connect.
        WCSession.default.activate()
    }
    #endif

    nonisolated public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        guard let data = applicationContext["pet"] as? Data,
              let pet = try? JSONDecoder().decode(PetState.self, from: data) else { return }
        Task { @MainActor [weak self] in
            self?.onPetReceived?(pet)
        }
    }

    nonisolated public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let data = message["msg"] as? Data,
              let msg = try? JSONDecoder().decode(ConnectivityMessage.self, from: data) else { return }
        Task { @MainActor [weak self] in
            self?.onMessage?(msg)
        }
    }
}
#endif
