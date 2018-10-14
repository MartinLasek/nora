final class HashtagGroup {
    var id: Int?
    let name: String
    var hashtags: [Hashtag]

    init(id: Int? = nil, name: String, hashtags: [Hashtag] = [Hashtag]()) {
        self.id = id
        self.name = name
        self.hashtags = hashtags
    }
}
