import Foundation

struct Manifest: Codable {
    let timestamp: Date
    let videos: [PlaybackItem]
}

struct PlaybackItem: Codable {
    let id: Int
    let vimeoId: String
    let location: String
    let author: String
    let params: [String: String]

    private enum CodingKeys: String, CodingKey {
        case id
        case vimeoId = "url"
        case location
        case author
        case params
    }
}
