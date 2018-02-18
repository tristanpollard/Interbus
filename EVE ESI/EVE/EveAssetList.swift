//
// Created by Tristan Pollard on 2017-12-18.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class EveAssetList {

    let esi = ESIClient.sharedInstance

    unowned var character : EveAuthCharacter
    var assetList : [EveAsset]

    init(_ character : EveAuthCharacter){
        self.character = character
        assetList = [EveAsset]()
    }

    func loadAllAssetsForCharacter(nextPage: Int = 1, completionHandler: @escaping() -> ()){

        let page = max(1, nextPage)

        if page <= 1{
            assetList.removeAll()
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
            let assetArr = Mapper<EveAsset>().mapArray(JSONArray: assets)
            for asset in assetArr{
                self.assetList.append(asset)
            }
        }

    }

    func processAssets(){
        for asset in self.assetList{
            if asset.location_type == "other" && asset.location_flag.lowercased() != "hangar"{
                //Subitem

                guard let parent = self.assetList.first(where: {$0.item_id == asset.location_id}) else{
                    debugPrint("Parent Asset Not Found...", asset.location_type, asset.location_flag)
                    continue
                }


                parent.childrenAssets.append(asset)
                asset.parentAsset = parent

            }
        }
    }


    /*
    func loadLocations(completionHandler: @escaping() -> ()){

        let stationIds : [Int64] = Set(self.assetList.filter({$0.location_type == "station"}).map({$0.location_id})).map({$0})
        let citadelIds : [Int64] = Set(self.assetList.filter({$0.location_type == "other"}).map({$0.location_id})).map({$0})

        let group = DispatchGroup()

        var assetLocations = [Int64 : String]()

        group.enter()
        stationIds.loadNames(){ names in

            assetLocations.merge(dict: names)

            group.leave()

        }

        var citadelLocations = [Int64 : String]()

        for cid in citadelIds{
            group.enter()
            self.character.loadStructure(cid){ name in

                citadelLocations.merge(dict: name)

                group.leave()
            }
        }

        group.notify(queue: .main){


            completionHandler()
        }

    }*/


}
