import Foundation

struct HashtagGroupRepository {
    private let archiveKey = "hashtagGroupList"
    let archiver = NSKeyedArchiver(requiringSecureCoding: false)

    // MARK: Store

    // Stores a list of hashtag groups.
    func store(_ hashtagGroupList: [HashtagGroup]) throws {
        let wrapper = HashtagGroupListWrapper(hashtagGroupList: hashtagGroupList)
        try archiver.encodeEncodable(wrapper, forKey: archiveKey)
        let data = archiver.encodedData
        UserDefaults.standard.set(data, forKey: archiveKey)
    }

    // Stores a single hashtag group
    // It will retrieve the whole hashtag group list,
    // find the new hashtagGroup in that list, replace it
    // and store the whole hashtag group list again.
    func store(_ hashtagGroup: HashtagGroup) throws {
        guard
            var hashtagGroupList = try retrieveHashtagGroupList(),
            let index = hashtagGroupList.firstIndex(where: { $0.name == hashtagGroup.name})
        else { return }

        hashtagGroupList[index] = hashtagGroup
        try store(hashtagGroupList)
    }

    // MARK: Retrieve

    // Retrieves a list of hashtag groups.
    func retrieveHashtagGroupList() throws -> [HashtagGroup]? {
        guard
            let data = UserDefaults.standard.data(forKey: archiveKey)
        else {
            return nil
        }

        let wrapper = try NSKeyedUnarchiver(forReadingFrom: data)
            .decodeDecodable(HashtagGroupListWrapper.self, forKey: archiveKey)
        return wrapper?.hashtagGroupList
    }
}

extension HashtagGroupRepository {
    struct HashtagGroupListWrapper: Codable {
        let hashtagGroupList: [HashtagGroup]
    }
}
