import Foundation

/// Deterministic algorithm that decides which evolution path a creature follows
/// given a window of daily HealthSnapshots.
public enum EvolutionEngine {

    /// Score how much each evolution path was reinforced across the window.
    /// Returns values in [0, 1], normalised so they sum to roughly 1.
    public static func pathScores(from snapshots: [HealthSnapshot]) -> [EvolutionPath: Double] {
        guard !snapshots.isEmpty else {
            return Dictionary(uniqueKeysWithValues: EvolutionPath.allCases.map { ($0, 0.2) })
        }

        // Per-snapshot normalised contributions
        var totals: [EvolutionPath: Double] = [:]
        for snap in snapshots {
            // Normalise each metric to ~[0, 1] using soft caps.
            let stepScore     = min(Double(snap.steps) / 10_000.0, 1.0)
            let hrScore       = min(Double(snap.heartRateZoneMinutes) / 30.0, 1.0)
            let standScore    = min(Double(snap.standHours) / 12.0, 1.0)
            let sleepScore    = min(snap.sleepHours / 8.0, 1.0)
            let workoutScore  = min(Double(snap.workoutMinutes) / 30.0, 1.0)

            totals[.wanderer, default: 0] += stepScore
            totals[.warrior,  default: 0] += hrScore
            totals[.sage,     default: 0] += standScore
            totals[.dreamer,  default: 0] += sleepScore
            totals[.master,   default: 0] += workoutScore
        }

        // Normalise across paths
        let sum = totals.values.reduce(0, +)
        guard sum > 0 else {
            return Dictionary(uniqueKeysWithValues: EvolutionPath.allCases.map { ($0, 0.2) })
        }
        return totals.mapValues { $0 / sum }
    }

    /// Choose the dominant evolution path. Ties are broken by EvolutionPath order
    /// (wanderer < warrior < sage < dreamer < master) for determinism.
    public static func dominantPath(from snapshots: [HealthSnapshot]) -> EvolutionPath {
        let scores = pathScores(from: snapshots)
        let ordered = EvolutionPath.allCases.map { ($0, scores[$0] ?? 0) }
        return ordered.max(by: { $0.1 < $1.1 })?.0 ?? .wanderer
    }

    /// How much total nourishment the creature has received. Used for stage progression.
    /// Returns a value typically between 0 and `snapshots.count`.
    public static func nourishment(from snapshots: [HealthSnapshot]) -> Double {
        pathScores(from: snapshots).values.reduce(0, +) * Double(snapshots.count)
    }

    /// Given total nourishment, return the current life stage.
    /// Thresholds calibrated for ~14 days to reach `.evolved`.
    public static func stage(forNourishment value: Double) -> LifeStage {
        switch value {
        case ..<1.0:   return .egg
        case ..<3.0:   return .baby
        case ..<7.0:   return .young
        case ..<12.0:  return .adult
        default:       return .evolved
        }
    }
}
