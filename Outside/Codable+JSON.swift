import Foundation

extension Decodable {
    public init?(
        json data: Data,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        self.init(json: data, decoder: decoder)
    }

    public init?(
        json data: Data,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        do {
            self = try decoder.decode(Self.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Failed to decode \(data) due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
            return nil
        } catch DecodingError.typeMismatch(_, let context) {
            print("Failed to decode \(data) due to type mismatch – \(context.debugDescription)")
            return nil
        } catch DecodingError.valueNotFound(let type, let context) {
            print("Failed to decode \(data) due to missing \(type) value – \(context.debugDescription)")
            return nil
        } catch DecodingError.dataCorrupted(_) {
            print("Failed to decode \(data) because it appears to be invalid JSON")
            return nil
        } catch {
            print("Failed to decode \(data): \(error.localizedDescription)")
            return nil
        }
    }
}

extension Encodable {
    public func json(
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys
    ) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy
        encoder.keyEncodingStrategy = keyEncodingStrategy

        do {
            return try encoder.encode(self)
        } catch EncodingError.invalidValue(_, let context) {
            print("Failed to encode \(self) due to type mismatch – \(context.debugDescription)")
            return nil
        } catch {
            print("Failed to encode \(self): \(error.localizedDescription)")
            return nil
        }
    }
}
