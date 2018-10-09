final class HashtagGroup: Codable {
    // `name` is the identifier and must be unique
    let name: String
    var hashtags: [Hashtag]

    init(name: String, hashtags: [Hashtag] = [Hashtag]()) {
        self.name = name
        self.hashtags = hashtags
    }
}
