import Foundation

enum URLSessionError: Error {
    case dataError
}

extension URLSession {
    func perform<T: Decodable>(
        _ request: URLRequest,
        decode decodable: T.Type,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) async throws -> T {
        let (data, _) = try await URLSession.shared.data(for: request)

        guard let object = T(json: data, dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy) else {
            throw URLSessionError.dataError
        }

        return object
    }
}
