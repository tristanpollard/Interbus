//
// Created by Tristan Pollard on 2017-12-18.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class EveAssetList {

    let esi = ESIClient.sharedInstance

    var character : EveAuthCharacter!
    var assetList = [EveAsset]()
    var assetLocations = [Int64:String]()

    func loadAllAssetsForCharacter(nextPage: Int = 1, completionHandler: @escaping() -> ()){

        let page = max(1, nextPage)

        if page <= 1{
            self.assetList = [EveAsset]()
        }

        let params : Parameters = ["page" : page]
        esi.invoke(endPoint: "/characters/\(character.id)/assets/", parameters: params, token: character.token){ response in
            self.addESIResponse(response: response)

            if let result = response.result as? [[String:Any]], let numPages = response.rawResponse.response?.allHeaderFields["x-pages"] as? String, let pages = Int(numPages){
                if result.count > 0 && page < pages{
                    self.loadAllAssetsForCharacter(nextPage: page + 1) {
                        completionHandler()
                    }
                }else{
                    completionHandler()
                }
            }else{
                completionHandler()
            }

        }

    }

    func addESIResponse(response: ESIResponse){

        if let assets = response.result as? [[String:Any]] {
            let assetList = Mapper<EveAsset>().mapArray(JSONArray: assets)
            self.assetList.append(contentsOf: assetList)
        }

    }

    func loadLocations(completionHandler: @escaping() -> ()){

        self.assetLocations.removeAll()

        let stationIds : [Int64] = Set(self.assetList.filter({$0.location_type == "station"}).map({$0.location_id})).map({$0})
        let citadelIds : [Int64] = Set(self.assetList.filter({$0.location_type == "other"}).map({$0.location_id})).map({$0})

        stationIds.loadNames(){ names in

            self.assetLocations.merge(dict: names)

            if citadelIds.count > 0{
                self.assetLocations[0] = "Citadels"
            }

            completionHandler()
        }

    }

    func assetsForLocation(location: Int64) -> [EveAsset]{
        if location == 0{
            return self.assetList.filter({$0.location_type == "other"}) //citadels
        }

        return self.assetList.filter({$0.location_id == location})
    }

}
