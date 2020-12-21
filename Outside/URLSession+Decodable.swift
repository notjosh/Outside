import Foundation

enum URLSessionError: Error {
    case dataError
}

extension URLSession {
    func perform<T: Decodable>(_ request: URLRequest, decode decodable: T.Type, result: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { (data, response, error) in

            // handle error scenarios... `result(.failure(error))`
            // handle bad response... `result(.failure(responseError))`
            // handle no data... `result(.failure(dataError))`

            guard let data = data else {
                result(.failure(URLSessionError.dataError))
                return
            }

            do {
                let object = try JSONDecoder().decode(decodable, from: data)
                result(.success(object))
            } catch {
                result(.failure(error))
            }

        }.resume()

    }

}
