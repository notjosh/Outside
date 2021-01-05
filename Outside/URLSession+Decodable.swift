import Foundation

enum URLSessionError: Error {
    case dataError
}

extension URLSession {
    func perform<T: Decodable>(
        _ request: URLRequest,
        decode decodable: T.Type,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        result: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                result(.failure(error))
                return
            }

            // handle error scenarios... `result(.failure(error))`
            // handle bad response... `result(.failure(responseError))`
            // handle no data... `result(.failure(dataError))`

            guard let data = data else {
                result(.failure(URLSessionError.dataError))
                return
            }
            
            if
                let object = T(
                    json: data,
                    dateDecodingStrategy: dateDecodingStrategy,
                    keyDecodingStrategy: keyDecodingStrategy
                )
            {
                result(.success(object))
            } else {
                result(.failure(URLSessionError.dataError))
                return
            }
        }

        task.resume()

        return task
    }
}
