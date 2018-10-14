import Foundation

final class InstagramClient {
    private let instagramRequestBuilder: IGRequestBuilder

    init() {
        self.instagramRequestBuilder = IGRequestBuilder()
    }

    func searchInstagram(for hashtagName: String, completion: @escaping (_ hashtags: Hashtag.SearchResponse) -> Void) {
        let searchHashtagRequest = instagramRequestBuilder.searchHashtag(by: hashtagName)
        let task = URLSession.shared.dataTask(with: searchHashtagRequest!) {(data, response, error) in

            guard error == nil else {
                print("error")
                return
            }

            guard let content = data else {
                print("no data")
                return
            }

            var hashtagResponse: Hashtag.SearchResponse
            do {
                hashtagResponse = try JSONDecoder().decode(Hashtag.SearchResponse.self, from: content)
            } catch {
                print("cannot decode response from instagram to HashtagResponse")
                return
            }

            DispatchQueue.main.async {
                completion(hashtagResponse)
            }
        }

        task.resume()
    }
}
