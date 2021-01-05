import Foundation

extension Formatter {
    static var iso8601withFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter
    }()
}

extension JSONEncoder.DateEncodingStrategy {
    static let iso8601withFractionalSeconds = JSONEncoder.DateEncodingStrategy.custom { date, encoder throws -> Void in
        var container = encoder.singleValueContainer()
        try container.encode(Formatter.iso8601withFractionalSeconds.string(from: date))
    }
}

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601withFractionalSeconds = JSONDecoder.DateDecodingStrategy.custom { decoder -> Date in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        guard
            let date = Formatter.iso8601withFractionalSeconds.date(from: dateString)
        else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date value doesn't look like an ISO8601 string."
            )
        }

        return date
    }
}

extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T? {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        return T(json: data, dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy)
    }
}
