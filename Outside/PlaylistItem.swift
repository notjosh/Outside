import Foundation

struct Manifest: Codable {
    let timestamp: Date
    let videos: [PlaybackItem]
}

struct PlaybackItem: Codable {
    let id: String
    let location: String
    let author: String
    let params: [String: String]

    private enum CodingKeys: String, CodingKey {
        case id
        case location
        case author
        case params
    }
}
