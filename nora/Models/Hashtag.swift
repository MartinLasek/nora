final class Hashtag {
    var id: Int?
    let name: String
    let usages: Int
    var state: State

    // foreign key
    let hashtagGroupId: Int

    init(id: Int? = nil, name: String, usages: Int, state: State = .none, hashtagGroupId: Int) {
        self.id = id
        self.name = name
        self.usages = usages
        self.state = state
        self.hashtagGroupId = hashtagGroupId
    }
}

extension Hashtag {
    enum State: String {
        case none = ""
        case added
        case selected
    }
}

extension Hashtag {
    struct SearchResponse: Decodable {
        let data: [HashtagData]
        let meta: HashtagMeta

        struct HashtagData: Decodable {
            let name: String
            let mediaCount: Int

            enum CodingKeys: String, CodingKey {
                case name
                case mediaCount = "media_count"
            }
        }

        struct HashtagMeta: Decodable {
            let code: Double
        }
    }
}
