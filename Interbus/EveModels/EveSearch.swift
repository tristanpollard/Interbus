import Foundation
import ObjectMapper

class EveSearch {
    static func search(_ q: String, categories: [EveSearchCategory] = [.character, .corporation, .alliance], completion: @escaping ([EveSearchResult]) -> ()) {
        let esi = ESIClient.sharedInstance
        let options: [ESIClientOptions: Any] = [
            .parameters: [
                "search": q,
                "categories": categories.map {
                    $0.rawValue
                }.joined(separator: ",")
            ]
        ]
        esi.invoke(endPoint: "/v2/search", options: options) { response in
            var searchResults: [EveSearchResult] = []
            if let result = response.result as? [String: [Int64]] {
                result.forEach { key, ids in
                    ids.forEach { id in
                        searchResults.append(EveSearchResult(id, category: EveSearchCategory(rawValue: key)!))
                    }
                }
            }
            completion(searchResults)
        }
    }
}
