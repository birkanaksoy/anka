import Foundation

public enum AppGroup {
    public static let identifier = "group.com.birkanaksoy.anka"

    public static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }
}
