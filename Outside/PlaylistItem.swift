import Foundation

struct PlaybackItem: Decodable {
    let id: Int
    let vimeoId: String
    let location: String
    let author: String

    private enum CodingKeys: String, CodingKey {
        case id
        case vimeoId = "url"
        case location
        case author
    }
}