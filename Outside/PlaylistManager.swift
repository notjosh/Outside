import Foundation

let remoteJSONURL = URL(string: "https://raw.githubusercontent.com/notjosh/Outside/main/Outside/videos.v2.json")!

class PlaylistManager {
    static var shared: PlaylistManager = {
        return PlaylistManager()
    }()

    private var task: Task<Manifest?, Never>?
    private let fileManager = FileManager.default

    private var cachedFileURL: URL {
        let documentDirectory = try! fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let fileURL = documentDirectory.appendingPathComponent("videos.v2.json")
        return fileURL
    }

    func load() async -> Playlist {
        let manifest = await loadManifest()

        return Playlist(items: manifest.videos)
    }

    func clearCache() {
        try? fileManager.removeItem(at: cachedFileURL)
    }

    private func loadManifest() async -> Manifest {
        let downloaded = await downloadLatestManifest()

        let cached = loadFromCache()
        let resources = loadFromResources()

        let local: Manifest

        if let cached = cached,
           cached.timestamp > resources.timestamp {
            print("local = cached (timestamp: \(cached.timestamp))")
            local = cached
        } else {
            print("local = resources (timestamp: \(resources.timestamp))")
            local = resources
        }

        if
            let downloaded = downloaded,
            downloaded.timestamp > local.timestamp
        {
            print("using downloaded (timestamp: \(downloaded.timestamp))")
            self.save(manifest: downloaded)
            return downloaded
        }

        print("using local")
        return local
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
                from: "videos.v2.json",
                dateDecodingStrategy: .iso8601withFractionalSeconds
            )
        else {
            fatalError("videos.v2.json is so broken, this is a bad time")
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

    private func downloadLatestManifest() async -> Manifest? {
        if let task = task {
            task.cancel()
            self.task = nil
        }

        let task = Task<Manifest?, Never> {
            let request = URLRequest(url: remoteJSONURL)

            do {
                let object = try await URLSession.shared.perform(request, decode: Manifest.self, dateDecodingStrategy: .iso8601withFractionalSeconds)

                print("downloaded manifest")
                return object
            } catch {
                print("failed to download manifest from \(remoteJSONURL)", error)
                return nil
            }
        }

        self.task = task

        return await task.value
    }
}
