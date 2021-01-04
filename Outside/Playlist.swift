import Foundation


class Playlist {
    private let items: [PlaybackItem]

    private var index: Int?

    init(items: [PlaybackItem]) {
        self.items = items
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
