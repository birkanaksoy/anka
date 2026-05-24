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
            return "Türk-Pers mitolojisinin ölümsüz kuşu. Kül olur, küllerinden doğar."
        case .sahmaran:
            return "Anadolu efsanesinin yılan-kız bilgesi. Yer altının sırlarını bilir."
        case .hodag:
            return "Karanlık ormanın koruyucu yaratığı. Geceleri görünür."
        case .karakoncolos:
            return "Kış gecelerinin yaratığı. Karda gezenleri sınar."
        case .pirebatak:
            return "Hızlı ve şefkatli yardımcı ruh. Çocuk masallarının dostu."
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
        case .egg:     return "Yumurta"
        case .baby:    return "Yavru"
        case .young:   return "Genç"
        case .adult:   return "Erişkin"
        case .evolved: return "Evrimleşmiş"
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
        case .wanderer: return "Yolcu"
        case .warrior:  return "Savaşçı"
        case .sage:     return "Bilge"
        case .dreamer:  return "Rüya"
        case .master:   return "Usta"
        }
    }
}
