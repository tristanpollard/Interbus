//
// Created by Tristan Pollard on 2018-02-17.
// Copyright (c) 2018 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveType : Nameable, Mappable {

    init(_ type_id: Int64){
        self.type_id = type_id
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.type_id <- map["type_id"]
        self.name <- map["name"]
        self.description <- map["description"]
        self.published <- map["published"]
        self.group_id <- map["group_id"]
        self.market_group_id <- map["market_group_id"]
        self.radius <- map["radius"]
        self.volume <- map["volume"]
        self.packaged_volume <- map["packaged_volume"]
        self.icon_id <- map["icon_id"]
        self.capacity <- map["capacity"]
        self.portion_size <- map["portion_size"]
        self.mass <- map["mass"]
        self.graphic_id <- map["graphic_id"]
    }

    func loadType(completionHandler: @escaping() -> ()){
        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/universe/types/\(self.type_id!)/"){ response in

            if let result = response.result as? [String:Any]{
                Mapper<EveType>().map(JSON: result, toObject: self)
            }

            completionHandler()

        }
    }

    var id : Int64 {
        get{
            return self.type_id!
        }
    }

    var type_id : Int64?
    var name  = ""
    var description : String?
    var published : String?
    var group_id : Int64?
    var market_group_id : Int64?
    var radius : Double?
    var volume : Double?
    var packaged_volume : Double?
    var icon_id : Int?
    var capacity : Double?
    var portion_size : Int?
    var mass : Double?
    var graphic_id : Int?

}
