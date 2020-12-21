import Foundation

struct VimeoConfigurationVideo: Decodable {
    let duration: Int
    let title: String

    private enum CodingKeys: String, CodingKey {
        case duration
        case title
    }

    private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional

        return formatter
    }()

    var durationHumanReadable: String {
        return durationFormatter.string(from: TimeInterval(duration)) ?? "00:00:00"
    }
}

struct VimeoConfigurationProgressiveFile: Decodable {
    let profile: Int
    let width: Int
    let height: Int
    let mime: String
    let fps: Int
    let url: URL
    let cdn: String
    let quality: String
//    let id: String // can be number or string, but we're not using either at the moment so can be ignored
    let origin: String
}

struct VimeoConfigurationFiles: Decodable {
    let progressive: [VimeoConfigurationProgressiveFile]
}

struct VimeoConfigurationRequest: Decodable {
    let files: VimeoConfigurationFiles
}

struct VimeoConfiguration: Decodable {
    let request: VimeoConfigurationRequest
    let video: VimeoConfigurationVideo
}

enum VimeoError: Error {
    case noSuitableSizeFound
}

class Vimeo {
    init() {
        // TODO: preferences, max size (1080p/4k/etc)
    }

    func fetchPlaybackURL(of id: String, callback: @escaping (Result<URL, Error>) -> Void) {
        let configURL = "https://player.vimeo.com/video/\(id)/config"

        print("fetching ID: \(id)")

        let url = URL(string: configURL)!
        let request = URLRequest(url: url)

        URLSession.shared.perform(request, decode: VimeoConfiguration.self) { (result) in
            switch result {
            case .failure(let error):
                return callback(.failure(error))
            case .success(let object):
                print("found: \(object.video.title) (\(object.video.durationHumanReadable))")
                let candidates = object.request.files.progressive
                    .sorted(by: { $0.height > $1.height })
                    .filter { $0.height <= 1080 }
                    .map { $0.url }

                guard let url = candidates.first else {
                    return callback(.failure(VimeoError.noSuitableSizeFound))
                }

                return callback(.success(url))
            }
        }
    }
}
