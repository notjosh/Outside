import Foundation
import ScreenSaver
import OSLog

class Preferences {
    static var shared: Preferences = {
        return Preferences()
    }()

    @Storage(key: "RandomisePlayback", defaultValue: true)
    var randomisePlayback: Bool

    @Storage(key: "MuteAudio", defaultValue: true)
    var muteAudio: Bool

    @Storage(key: "HighestQuality", defaultValue: StreamingQuality.q1080p)
    var highestQuality: StreamingQuality
}

enum StreamingQuality: Int, Codable, CaseIterable {
    case q4k = 2160
    case q1080p = 1080
    case q480p = 480

    var title: String {
        switch self {
        case .q480p: return "480p"
        case .q1080p: return "1080p"
        case .q4k: return "4k"
        }
    }

    var size: CGSize {
        switch self {
        case .q480p: return CGSize(width: 640, height: 480)
        case .q1080p: return CGSize(width: 1920, height: 1080)
        case .q4k: return CGSize(width: 3840, height: 2160)
        }
    }
}

// via https://github.com/glouel/ScreenSaverMinimal/

// This retrieves/store any type of property in our plist as a readable JSON
@propertyWrapper struct Storage<T: Codable> {
    private let key: String
    private let defaultValue: T
    private let module = Bundle(for: Preferences.self).bundleIdentifier!

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            if let userDefaults = ScreenSaverDefaults(forModuleWithName: module) {
                guard let jsonString = userDefaults.string(forKey: key) else {
                    return defaultValue
                }
                guard let jsonData = jsonString.data(using: .utf8) else {
                    return defaultValue
                }
                guard let value = try? JSONDecoder().decode(T.self, from: jsonData) else {
                    return defaultValue
                }
                return value
            }

            return defaultValue
        }
        set {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]

            let jsonData = try? encoder.encode(newValue)
            let jsonString = String(bytes: jsonData!, encoding: .utf8)

            if let userDefaults = ScreenSaverDefaults(forModuleWithName: module) {
                // Set value to UserDefaults
                userDefaults.set(jsonString, forKey: key)

                // We force the sync so the settings are automatically saved
                // This is needed as the System Preferences instance of Aerial
                // is a separate instance from the screensaver ones
                userDefaults.synchronize()
            } else {
                if #available(OSX 10.12, *) {
                    let log = OSLog(subsystem: module, category: "Screensaver")
                    os_log("ScreenSaverMinimal: %{public}@", log: log, type: .error, "UserDefaults set failed for \(key)")
                } else {
                    NSLog("ScreenSaverMinimal: UserDefaults set failed for \(key)")
                }
            }
        }
    }
}

// This retrieves store "simple" types that are natively storable on plists
@propertyWrapper struct SimpleStorage<T> {
    private let key: String
    private let defaultValue: T
    private let module = Bundle.main.bundleIdentifier!
    // TODO: If you want to share settings between your app target and your saver target, you can manually set a value here. Be aware that in Catalina+, your settings will be sandboxed though !

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            if let userDefaults = ScreenSaverDefaults(forModuleWithName: module) {
                return userDefaults.object(forKey: key) as? T ?? defaultValue
            }

            return defaultValue
        }
        set {
            if let userDefaults = ScreenSaverDefaults(forModuleWithName: module) {
                userDefaults.set(newValue, forKey: key)

                userDefaults.synchronize()
            }
        }
    }
}
