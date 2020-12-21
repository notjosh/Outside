import Foundation

enum QualityPreference {
    case q4k
    case q1080p

    var height: Int {
        switch self {
        case .q4k:
            return 2160
        case .q1080p:
            return 1080
        }
    }
}

class Preferences {
    let randomisePlayback = false
    let muteAudio = true
    let highestQuality = QualityPreference.q1080p.height
}
