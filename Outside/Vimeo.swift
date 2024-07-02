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
        return durationFormatter.string(from: TimeInterval(duration))
            ?? "00:00:00"
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
    let origin: String
}

struct VimeoConfigurationFiles: Decodable {
    let hls: VimeoConfigurationHls
    let progressive: [VimeoConfigurationProgressiveFile]?
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

    lazy var vimeoURLSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        let cookieStorage = HTTPCookieStorage.shared
        configuration.httpCookieStorage = nil

        return URLSession(configuration: configuration)
    }()

    func fetchPlaybackURL(
        of id: String, params: [String: String], maximumHeight: Int = 1080,
        callback: @escaping (Result<(URL, VimeoConfigurationVideo), Error>) ->
            Void
    ) {
        let configURL = "https://player.vimeo.com/video/\(id)"

        var urlComponents = URLComponents(string: configURL)!
        urlComponents.queryItems = params.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        var request = URLRequest(url: urlComponents.url!)

        // making us look like a browser with DNT seems to help avoid some cloudflare nonsense, so...try that
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:128.0) Gecko/20100101 Firefox/128.0",
            forHTTPHeaderField: "User-Agent")
        request.setValue("1", forHTTPHeaderField: "DNT")

        if let task = task, task.state == .running {
            task.cancel()
            self.task = nil
        }

        task = vimeoURLSession.dataTask(with: request) { (data, _, error) in
            if let error = error {
                return callback(.failure(error))
            }

            guard let data = data,

                  // read `data` as string, so we can parse the HTML
                  let html = String(data: data, encoding: .utf8),

                  // extract the JSON from the HTML
                  let json = VimeoConfigExtractor(html: html).json,

                  // convert back to `Data` for `Codable` to do its thing
                  let jsonData = json.data(using: .utf8),

                  // make the model object, probably with junk HTML at the end of the JSON string (...so do it lenient!)
                  let object = VimeoConfiguration(
                      json: jsonData,
                      decoder: LenientJSONDecoder()
                  )
            else {
                return callback(.failure(URLSessionError.dataError))
            }

            print(
                "found config for: \(object.video.title) (\(object.video.durationHumanReadable))"
            )

            print("trying HLS...")
            let hls = object.request.files.hls
            let defaultCdn = hls.default_cdn

            if let cdn = hls.cdns[defaultCdn] {
                print("found HLS config for CDN: \(defaultCdn)")

                return callback(.success((cdn.url, object.video)))
            }

            print("trying direct video...")
            let candidates = (object.request.files.progressive ?? [])
                .sorted(by: { $0.height > $1.height })
                .filter { $0.height <= maximumHeight }
                .map { $0.url }

            if let url = candidates.first {
                print("found direct video at desired size")
                return callback(.success((url, object.video)))
            }

            return callback(.failure(VimeoError.noSuitableSizeFound))
        }

        task?.resume()
    }
}
