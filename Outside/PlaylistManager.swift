import Foundation

let remoteJSONURL = URL(string: "https://raw.githubusercontent.com/notjosh/Outside/main/Outside/videos.json")!

class PlaylistManager {
    static var shared: PlaylistManager = {
        return PlaylistManager()
    }()

    private var task: URLSessionDataTask?
    private let fileManager = FileManager.default

    private var cachedFileURL: URL {
        let documentDirectory = try! fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let fileURL = documentDirectory.appendingPathComponent("videos.json")
        return fileURL
    }

    func load(completion: @escaping (Playlist) -> Void) {
        loadManifest { manifest in
            completion(Playlist(items: manifest.videos))
        }
    }

    func clearCache() {
        try? fileManager.removeItem(at: cachedFileURL)
    }

    private func loadManifest(completion: @escaping (Manifest) -> Void) {
        downloadLatestManifest { [weak self] downloaded in
            guard let self = self else {
                return
            }

            let cached = self.loadFromCache()
            let resources = self.loadFromResources()

            let local: Manifest

            if let cached = cached,
               cached.timestamp > resources.timestamp {
//                print("local = cached (timestamp: \(cached.timestamp))")
                local = cached
            } else {
//                print("local = cached (timestamp: \(resources.timestamp))")
                local = resources
            }

            if
                let downloaded = downloaded,
                downloaded.timestamp > local.timestamp
            {
//                print("using downloaded (timestamp: \(downloaded.timestamp))")
                self.save(manifest: downloaded)
                return completion(downloaded)
            }

//            print("using local")
            return completion(local)
        }
    }

    private func loadFromCache() -> Manifest? {
        print("loading via cache: \(cachedFileURL)")

        guard
            let data = try? Data(contentsOf: cachedFileURL)
        else {
            return nil
        }

        return Manifest(
            json: data,
            dateDecodingStrategy: .iso8601withFractionalSeconds
        )
    }

    private func loadFromResources() -> Manifest {
        guard
            let manifest = Bundle(for: type(of: self)).decode(
                Manifest.self,
                from: "videos.json",
                dateDecodingStrategy: .iso8601withFractionalSeconds
            )
        else {
            fatalError("videos.json is so broken, this is a bad time")
        }

        return manifest
    }

    private func save(manifest: Manifest) {
        guard
            let data = manifest.json(dateEncodingStrategy: .iso8601withFractionalSeconds)
        else {
            return
        }

        try? data.write(to: cachedFileURL)
    }

    private func downloadLatestManifest(completion: @escaping (Manifest?) -> Void) {
        let request = URLRequest(url: remoteJSONURL)

        if let task = task, task.state == .running {
            task.cancel()
            self.task = nil
        }

        task = URLSession.shared.perform(
            request,
            decode: Manifest.self,
            dateDecodingStrategy: .iso8601withFractionalSeconds
        ) { (result) in
            switch result {
            case .failure(let error):
                print("failed to download manifest", error)
                return completion(nil)
            case .success(let object):
                print("downloaded manifest")
                return completion(object)
            }
        }
    }
}
