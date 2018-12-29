//
// Created by Tristan Pollard on 2018-12-28.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

enum AssetLocation: String {
    case station = "station"
    case solar_system = "solar_system"
    case other = "other"
    case hangar = "hangar"
}

class AssetGroup: Nameable {
    var assets: [EveAssetItem] = []
    var location_id: Int64
    var locationType: AssetLocation
    var id: Int64 {
        return self.location_id
    }
    var name: EveName?

    init(location: Int64, assets: [EveAssetItem], type: AssetLocation = .station) {
        self.location_id = location
        self.locationType = type
        self.assets = assets.sorted {
            var name0: String = $0.name!.name
            var name1: String = $1.name!.name

            if let customName0 = $0.assetName?.name {
                name0 = customName0
            }
            if let customName1 = $1.assetName?.name {
                name1 = customName1
            }

            return name0 < name1
        }
    }
}

class EveAssets {

    unowned var character: EveCharacter
    var rawAssets: [EveAssetItem] = []
    var assets: [AssetGroup] = [] // LocationID -> Assets

    init(character: EveCharacter) {
        self.character = character
    }

    func fetchAssetPage(page: Int = 1, completion: @escaping ([EveAssetItem], Int) -> ()) {
        var assets: [EveAssetItem] = []
        let esi = ESIClient.sharedInstance
        var pages = 1
        let options = [
            "parameters": ["page": page]
        ]
        esi.invoke(endPoint: "/v3/characters/\(self.character.id)/assets/", token: character.token, options: options) { response in
            if let result = response.result as? [[String: Any]] {
                if let pageString = response.rawResponse.response?.allHeaderFields["x-pages"] as? String, let pageCount = Int(pageString) {
                    pages = pageCount
                }
                assets += Mapper<EveAssetItem>().mapArray(JSONArray: result)
            }
            completion(assets, pages)
        }
    }

    func fetchAllAssets(page: Int = 1, completion: @escaping () -> ()) {
        var assets: [EveAssetItem] = []
        let group = DispatchGroup()

        group.enter()
        self.fetchAssetPage { fetchedAssets, pages in
            assets += fetchedAssets
            if pages > 1 {
                for i in 2...pages {
                    group.enter()
                    self.fetchAssetPage(page: i) { fetchedAssetsPages, _ in
                        assets += fetchedAssetsPages
                        group.leave()
                    }
                }
            }
            group.leave()
        }

        group.notify(queue: .main) {

            let nameGroup = DispatchGroup()
            nameGroup.enter()
            let filtered = assets.filter { asset in
                return asset.location_type.lowercased() == "other" && asset.location_flag.lowercased() == "hangar" && asset.is_singleton
            }
            filtered.fetchAssetNames(character: self.character) {
                nameGroup.leave()
            }

            nameGroup.enter()
            assets.fetchNames {
                nameGroup.leave()
            }


            nameGroup.notify(queue: .main) {
                self.rawAssets = assets
                self.assets = self.processAssets(assets: self.rawAssets)
                self.assets.filter {
                    $0.locationType == .station
                }.fetchNames {
                    self.assets.sort { left, right in
                        let defaultName = "Unknown Location"
                        var lName = defaultName
                        var rName = defaultName
                        if let leftName = left.name?.name {
                            lName = leftName
                        }
                        if let rightName = right.name?.name {
                            rName = rightName
                        }
                        return lName < rName
                    }
                    completion()
                }
            }
        }
    }

    func processAssets(assets: [EveAssetItem]) -> [AssetGroup] {
        var map: [Int64: [EveAssetItem]] = [:]

        var idToAssetMap: [Int64: EveAssetItem] = [:]
        assets.forEach { asset in
            idToAssetMap[asset.item_id] = asset
        }

        for asset in assets {
            // Item will have a parent
            if asset.location_type == "other" && asset.location_flag.lowercased() != "hangar" {
                guard let parent = idToAssetMap[asset.location_id] else {
                    debugPrint("Parent Asset Not Found...", asset.location_type, asset.location_flag)
                    continue
                }
                parent.childrenAssets.append(asset)
                asset.parentAsset = parent
            }

            if let _ = map[asset.location_id] {
                map[asset.location_id]!.append(asset)
            } else {
                map[asset.location_id] = [asset]
            }
        }

        return map.map { key, value in
            return AssetGroup(location: key, assets: value, type: AssetLocation(rawValue: value.first!.location_type)!)
        }
    }

}
