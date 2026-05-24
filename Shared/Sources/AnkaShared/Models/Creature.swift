import Foundation

public enum CreatureSpecies: String, Codable, CaseIterable, Sendable {
    case anka          // Phoenix
    case sahmaran      // Snake-queen
    case hodag         // Forest spirit
    case karakoncolos  // Winter spirit
    case pirebatak     // Fast helper spirit

    public var displayName: String {
        switch self {
        case .anka:         return "Anka"
        case .sahmaran:     return "Şahmaran"
        case .hodag:        return "Hodağ"
        case .karakoncolos: return "Karakoncolos"
        case .pirebatak:    return "Pirebatak"
        }
    }

    public var loreShort: String {
        switch self {
        case .anka:
            return "The immortal firebird of Turkic and Persian myth. Burns to ash, born from it again."
        case .sahmaran:
            return "The serpent-queen of Anatolian legend. Keeper of the secrets beneath the earth."
        case .hodag:
            return "Guardian of the dark forest. Only seen by those who walk at night."
        case .karakoncolos:
            return "Spirit of long winter nights. Tests those who wander through the snow."
        case .pirebatak:
            return "A swift and tender helper spirit. Friend of children's tales."
        }
    }
}

public enum LifeStage: Int, Codable, Comparable, Sendable {
    case egg = 0
    case baby = 1
    case young = 2
    case adult = 3
    case evolved = 4

    public static func < (lhs: LifeStage, rhs: LifeStage) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var displayName: String {
        switch self {
        case .egg:     return "Egg"
        case .baby:    return "Hatchling"
        case .young:   return "Young"
        case .adult:   return "Adult"
        case .evolved: return "Evolved"
        }
    }
}

public enum EvolutionPath: String, Codable, CaseIterable, Sendable {
    case wanderer  // step dominant
    case warrior   // heart rate zone dominant
    case sage      // stand hours dominant
    case dreamer   // sleep dominant
    case master    // workout dominant

    public var displayName: String {
        switch self {
        case .wanderer: return "Wanderer"
        case .warrior:  return "Warrior"
        case .sage:     return "Sage"
        case .dreamer:  return "Dreamer"
        case .master:   return "Master"
        }
    }
}
