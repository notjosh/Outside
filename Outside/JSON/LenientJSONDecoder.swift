// this class allows us to pass JSON with trailing mess (probably HTML) from a regex result.
// it's inefficient, as it means parsing the JSON twice under the hood. but at least it works :)
class LenientJSONDecoder: JSONDecoder {
    override func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        var rangeOfValidThings = data.startIndex..<data.endIndex

        do {
            var parser = JSONParser(bytes: Array(data))
            let _ = try parser.parse()
        } catch JSONError.unexpectedCharacter(_, let characterIndex) {
            // try to handle case where JSON has invalid trailing data
            rangeOfValidThings = data.startIndex..<data.index(data.startIndex, offsetBy: characterIndex)
        } catch {
            throw error
        }

        return try super.decode(type, from: data[rangeOfValidThings])
    }
}

extension LenientJSONDecoder: @unchecked Sendable {}
