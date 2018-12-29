//
// Created by Tristan Pollard on 2018-12-28.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveAssetItem: Mappable, Nameable, EVEImage {
    var id: Int64 {
        return Int64(self.type_id)
    }
    var name: EveName?
    var imageEndpoint: String = "Type"
    var imageID: Int64 {
        return self.id
    }
    var imageExtension: String = "png"
    var placeholder: UIImage = UIImage(named: "characterPlaceholder128.jpg")!

    var is_blueprint_copy: Bool?
    var is_singleton: Bool!
    var item_id: Int64!
    var location_flag: String!
    var location_id: Int64!
    var location_type: String!
    var quantity: Int!
    var type_id: Int!

    var parentAsset: EveAssetItem?
    var childrenAssets: [EveAssetItem] = []

    var assetName: EveName?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.is_blueprint_copy <- map["is_blueprint_copy"]
        self.is_singleton <- map["is_singleton"]
        self.item_id <- map["item_id"]
        self.location_flag <- map["location_flag"]
        self.location_id <- map["location_id"]
        self.location_type <- map["location_type"]
        self.quantity <- map["quantity"]
        self.type_id <- map["type_id"]
    }
}

extension Array where Element == EveAssetItem {
    func fetchAssetNames(character: EveCharacter, completion: @escaping () -> ()) {
        // Since we have specified element == EveAssetItem, we cannot use Array(Set())

        if self.count == 0 {
            completion()
            return
        }

        var unique: [Int64] = Set(self.map {
            $0.item_id
        }).map {
            $0
        }
        let esi = ESIClient.sharedInstance
        let group = DispatchGroup()
        var results: [Int64: EveName] = [:]

        stride(from: 0, to: unique.count, by: 200).forEach { sIndex in
            let end = unique.index(sIndex, offsetBy: 200)
            let endIndex = Swift.min(end, unique.count)
            let items = Swift.Array(unique[sIndex..<endIndex])
            let options: [String: Any] = [
                "parameters": items.asParameters(),
                "encoding": ArrayEncoding()
            ]
            group.enter()
            esi.invoke(endPoint: "/v1/characters/\(character.id)/assets/names", httpMethod: .post, token: character.token, options: options) { response in
                if let result = response.result as? [[String: Any]] {
                    let items = Mapper<EveName>(context: DefaultNameCategoryContext(category: .asset)).mapArray(JSONArray: result)
                    items.forEach { value in
                        results[value.id] = value
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            for item in self {
                if let name = results[item.item_id] {
                    item.assetName = name
                }
            }
            completion()
        }
    }
}
