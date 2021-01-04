import Foundation

let remoteJSONURL = URL(string: "https://raw.githubusercontent.com/notjosh/Outside/main/Outside/videos.json")!

class PlaylistManager {
    static var shared: PlaylistManager = {
        return PlaylistManager()
    }()

    func load(completion: @escaping (Playlist) -> Void) {
        let manifest = Bundle(for: type(of: self)).decode(
            Manifest.self,
            from: "videos.json",
            dateDecodingStrategy: .iso8601withFractionalSeconds
        )

        DispatchQueue.global(qos: .background).async {
            let playlist = Playlist(items: manifest.videos)
            completion(playlist)
        }
    }
}
