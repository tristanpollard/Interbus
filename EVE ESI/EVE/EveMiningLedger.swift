//
// Created by Tristan Pollard on 2017-12-18.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

class EveMiningLedger {

    var entries = [EveMiningLedgerEntry]()
    var summed = [EveMiningLedgerEntry]()
    var character : EveAuthCharacter!

    let esi = ESIClient.sharedInstance

    func loadAllMiningForCharacter(nextPage : Int = 1, completionHandler: @escaping() -> ()){

        let page = max(1, nextPage)

        if page <= 1{
            self.entries = [EveMiningLedgerEntry]()
        }

        let params : Parameters = ["page" : page]
        esi.invoke(endPoint: "/characters/\(character.id)/mining/", parameters: params, token: character.token){ response in
            self.addESIResponse(response: response)

            if let result = response.result as? [[String:Any]], let numPages = response.rawResponse.response?.allHeaderFields["x-pages"] as? String, let pages = Int(numPages){
                if result.count > 0 && page < pages{
                    self.loadAllMiningForCharacter(nextPage: page + 1) {
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
        if let miningEntries = response.result as? [[String:Any]]{
            let entries = Mapper<EveMiningLedgerEntry>().mapArray(JSONArray: miningEntries)
            self.entries.append(contentsOf: entries)
        }
    }

    func sumMining(){
        summed.removeAll()

        let ids = Set(entries.map({$0.type_id})).map({$0})
        for id in ids{
            let miningEntry = EveMiningLedgerEntry(type_id: id)
            let miningEntries = entries.filter({$0.type_id == id})
            for entry in miningEntries{
                miningEntry.quantity = miningEntry.quantity + entry.quantity //Swift bug? += doesn't work
            }
            summed.append(miningEntry)
        }

        summed.sort(by: {$0.quantity > $1.quantity})

    }

}
