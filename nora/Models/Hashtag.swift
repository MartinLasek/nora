final class Hashtag {
    let name: String
    let usages: Int
    var state: State

    init(name: String, usages: Int, state: State = .none) {
        self.name = name
        self.usages = usages
        self.state = state
    }
}

extension Hashtag {
    enum State: String {
        case none = ""
        case added = "already added"
        case selected
    }
}

extension Hashtag {
    struct SearchResponse: Decodable {
        let data: [SearchResponse.Data]
        let meta: SearchResponse.Meta

        struct Data: Decodable {
            let name: String
            let mediaCount: Int

            enum CodingKeys: String, CodingKey {
                case name
                case mediaCount = "media_count"
            }
        }

        struct Meta: Decodable {
            let code: Double
        }
    }
}
