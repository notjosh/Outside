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

struct VimeoConfigurationCdn: Decodable {
    let origin: String
    let url: URL
}

struct VimeoConfigurationHls: Decodable {
    let default_cdn: String
    let separate_av: Bool
    let cdns: [String: VimeoConfigurationCdn]
}

struct VimeoConfigurationProgressiveFile: Decodable {
    let width: Int
    let height: Int
    let url: URL
    let quality: String
//    let id: String // can be number or string, but we're not using either at the moment so can be ignored
    let origin: String
}

struct VimeoConfigurationFiles: Decodable {
    let hls: VimeoConfigurationHls
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
    var task: URLSessionDataTask?

    func fetchPlaybackURL(of id: String, params: [String: String], maximumHeight: Int = 1080, callback: @escaping (Result<(URL, VimeoConfigurationVideo), Error>) -> Void) {
        let configURL = "https://player.vimeo.com/video/\(id)/config"

        var urlComponents = URLComponents(string: configURL)!
        urlComponents.queryItems = params.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        let request = URLRequest(url: urlComponents.url!)

        if let task = task, task.state == .running {
            task.cancel()
            self.task = nil
        }

        task = URLSession.shared.perform(request, decode: VimeoConfiguration.self) { (result) in
            switch result {
            case .failure(let error):
                return callback(.failure(error))
            case .success(let object):
                print("found config for: \(object.video.title) (\(object.video.durationHumanReadable))")

                print("trying HLS...")
                let hls = object.request.files.hls
                let defaultCdn = hls.default_cdn

                if let cdn = hls.cdns[defaultCdn] {
                    print("found HLS config for CDN: \(defaultCdn)")

                    return callback(.success((cdn.url, object.video)))
                }

                print("trying direct video...")
                let candidates = object.request.files.progressive
                    .sorted(by: { $0.height > $1.height })
                    .filter { $0.height <= maximumHeight }
                    .map { $0.url }

                if let url = candidates.first {
                    print("found direct video at desired size")
                    return callback(.success((url, object.video)))
                }

                return callback(.failure(VimeoError.noSuitableSizeFound))
            }
        }
    }
}
