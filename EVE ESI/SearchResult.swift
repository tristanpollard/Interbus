//
// Created by Tristan Pollard on 2017-09-26.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import ObjectMapper

public class SearchResult : Mappable, CustomStringConvertible, Equatable{

    public enum SearchType: String{
        case agent, alliance, character, constellation, corporation, faction, inventory_type, region, solar_system, station

        static let allTypes = [agent, alliance, character, constellation, corporation, faction, inventory_type, region, solar_system, station]
    }

    var id : Int64!
    var name : String!
    var type : SearchType!

    init(id: Int64, name: String, type: SearchType){
        self.id = id
        self.name = name
        self.type = type
    }


    public static func ==(lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs === rhs
    }

    public var description: String {
        return "ID: \(self.id!) Name: \(self.name!) Type: \(self.type.rawValue)"
    }

    public required init?(map: Map) {

    }

    public func mapping(map: Map) {
        if let context = (map.context as? ESIContext)?.type{
            switch (context){
                case "alliances":
                    self.id <- map["alliance_id"]
                    self.name <- map["alliance_name"]
                    self.type = .alliance
                case "characters":
                    self.id <- map["character_id"]
                    self.name <- map["character_name"]
                    self.type = .character
                case "corporations":
                    self.id <- map["corporation_id"]
                    self.name <- map["corporation_name"]
                    self.type = .corporation
                case "stations":
                    self.id <- map["station_id"]
                    self.name <- map["name"]
                    self.type = .station
                case "systems":
                    self.id <- map["system_id"]
                    self.name <- map ["name"]
                    self.type = .solar_system
                default:
                    break
            }
        }
    }

    init(result: [String:AnyObject], type: SearchType){
        self.type = type
        switch (self.type){
            case .alliance:
                self.id = result["alliance_id"] as! Int64
                self.name = result["alliance_name"] as! String
            case .corporation:
                self.id = result["corporation_id"] as! Int64
                self.name = result["corporation_name"] as! String
            case .character:
                self.id = result["character_id"] as! Int64
                self.name = result["character_name"] as! String
            case .station:
                self.id = result["station_id"] as! Int64
                self.name = result["name"] as! String
            case .solar_system:
                self.id = result["system_id"] as! Int64
                self.name = result["name"] as! String
            default:
                debugPrint(result)
        }
    }

    func imageUrlForSearchResult() -> URL?{
        switch (self.type){
            case .character:
                return URL(string: "https://image.eveonline.com/Character/\(self.id!)_64.jpg")!
            case .corporation:
                return URL(string: "https://image.eveonline.com/Corporation/\(self.id!)_64.png")!
            case .alliance:
                return URL(string: "https://image.eveonline.com/Alliance/\(self.id!)_64.png")!
            default:
                return nil
        }
    }

    func placeHolderForSearchResult(size: Int = 64) -> UIImage?{
        return UIImage(named: "\(self.type.rawValue)Placeholder\(size).\(self.extensionForType())")
    }

    func extensionForType() -> String{
        switch (self.type){
            case .character:
                 return "jpg"
            default:
                return "png"
        }
    }

    func playerOwned() -> EvePlayerOwned?{
        switch (self.type){
            case .character:
                let char = EveCharacter(self.id)
                char.name = self.name
                return char
            case .corporation:
                let corp = EveCorporation(corporation_id: self.id)
                corp.name = self.name
                return corp
            case .alliance:
                let all = EveAlliance(alliance_id: self.id)
                all.name = self.name
                return all
            default:
                return nil
        }
    }
}

class SearchResults {

    let esi = ESIClient.sharedInstance
    let group = DispatchGroup()
    var results = [String:[SearchResult]]()

    func resultsForSearch(search: [String:[Int64]], completionHandler: @escaping () -> ()){

        for (key,ids) in search{
            switch (key){
            case SearchResult.SearchType.alliance.rawValue:
                fetchAlliances(alliance_ids: ids)
            case SearchResult.SearchType.corporation.rawValue:
                fetchCorporations(corporation_ids: ids)
            case SearchResult.SearchType.character.rawValue:
                fetchCharacters(character_ids: ids)
            case SearchResult.SearchType.station.rawValue:
                fetchStations(station_ids: ids)
            case SearchResult.SearchType.solar_system.rawValue:
                fetchSystems(system_ids: ids)
            default: break
            }
        }

        group.notify(queue: .main) {
            completionHandler()
        }
    }

    func searchForString(search: String, categories: [SearchResult.SearchType] = [.character], completionHandler: @escaping(SearchResult) -> ()){

        let params : Parameters = ["search" : search, "categories" : categories.map({$0.rawValue}).joined(separator: ","), "strict" : true]
        esi.invoke(endPoint: "/search/", parameters: params){ result in
            debugPrint(result.rawResponse)
            if let response = result.result as? [String:[Int64]] {
                if let chars = response["character"]{
                    if chars.count == 1{
                         completionHandler(SearchResult(id: chars[0], name: search, type: .character))
                        return
                    }
                }
            }
        }

    }

    func fetchAlliances(alliance_ids: [Int64]){
        group.enter()
        let parameters : Parameters = ["alliance_ids" : alliance_ids.map({String($0)}).joined(separator: ",")]
        esi.invoke(endPoint: "/alliances/names", parameters: parameters){ response in

            if let esiErr = response.error{
                print("ESI Error: \(esiErr)")
                return
            }

            if let alliances = response.result as? [[String:AnyObject]]{
                let context = ESIContext(type: "alliances")
                self.results["alliances"] = Mapper<SearchResult>(context: context).mapArray(JSONArray: alliances).sorted(by: {$0.name < $1.name})
                self.group.leave()
            }
        }
    }

    func fetchCorporations(corporation_ids: [Int64]){
        group.enter()
        let parameters : Parameters = ["corporation_ids" : corporation_ids.map({String($0)}).joined(separator: ",")]
        esi.invoke(endPoint: "/corporations/names", parameters: parameters){ response in

            if let esiErr = response.error{
                print("ESI Error: \(esiErr)")
                return
            }

            if let corporations = response.result as? [[String:AnyObject]]{
                let context = ESIContext(type: "corporations")
                self.results["corporations"] = Mapper<SearchResult>(context: context).mapArray(JSONArray: corporations).sorted(by: {$0.name < $1.name})
                self.group.leave()
            }
        }
    }

    func fetchCharacters(character_ids: [Int64]){
        group.enter()
        let parameters : Parameters = ["character_ids" : character_ids.map({String($0)}).joined(separator: ",")]
        esi.invoke(endPoint: "/characters/names", parameters: parameters){ response in

            if let esiErr = response.error{
                print("ESI Error: \(esiErr)")
                return
            }

            if let characters = response.result as? [[String:AnyObject]]{
                let context = ESIContext(type: "characters")
                self.results["characters"] = Mapper<SearchResult>(context: context).mapArray(JSONArray: characters).sorted(by: {$0.name < $1.name})
                self.group.leave()
            }
        }
    }

    func fetchStations(station_ids: [Int64]){
        var stations = [SearchResult]()
        for id in station_ids{
            group.enter()
            esi.invoke(endPoint: "/universe/stations/\(id)") { response in

                if let esiErr = response.error{
                    print("ESI Error: \(esiErr)")
                    return
                }

                if let station = response.result as? [String: AnyObject] {
                    let context = ESIContext(type: "stations")
                    stations.append(Mapper<SearchResult>(context: context).map(JSON: station)!)
                    self.results["stations"] = stations.sorted(by: {$0.name < $1.name})
                    self.group.leave()
                }
            }
        }
    }

    func fetchSystems(system_ids: [Int64]){
        var systems = [SearchResult]()
        for id in system_ids{
            group.enter()
            esi.invoke(endPoint: "/universe/systems/\(id)"){ response in

                if let err = response.error{
                    print("ESI Error: \(err)")
                    return
                }

                if let system = response.result as? [String:AnyObject]{
                    let context = ESIContext(type: "systems")
                    systems.append(Mapper<SearchResult>(context: context).map(JSON: system)!)
                    self.results["systems"] = systems.sorted(by: {$0.name < $1.name})
                    self.group.leave()
                }
            }
        }
    }



}

extension SearchResults: CustomStringConvertible {
    var description: String {
        return "\(self.results)"
    }
}