import Foundation

struct Manifest: Decodable {
    let timestamp: Date
    let videos: [PlaybackItem]
}

class Playlist {
    private let items: [PlaybackItem]

    private var index: Int?

    init() {
        let manifest = Bundle(for: type(of: self)).decode(
            Manifest.self,
            from: "videos.json",
            dateDecodingStrategy: .iso8601withFractionalSeconds
        )

        items = manifest.videos
    }

    func next(randomised: Bool) -> PlaybackItem? {
        guard !items.isEmpty else {
            fatalError("playlist is empty, so we bailed instead")
        }

        guard let previousIndex = index else {
            index = randomised ? Int.random(in: 0..<items.count) : 0
            return items[index ?? 0]
        }

        if randomised {
            // avoid playing the same back-to-back
            repeat {
                index = Int.random(in: 0..<items.count)
            } while items.count > 1 && index == previousIndex
        } else {
            index = (previousIndex + 1) % items.count
        }

        return items[index ?? 0]
    }
}
