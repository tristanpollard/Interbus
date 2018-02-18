//
// Created by Tristan Pollard on 2017-12-18.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveAsset : Mappable, Nameable{

    var name: String = ""
    var id : Int64{
        get{
            return self.type_id
        }
    }

    var is_singleton : Bool!
    var item_id : Int64!
    var location_id : Int64!
    var location_flag: String!
    var location_type : String!
    var quantity : Int!
    var type_id : Int64!

    var parentAsset : EveAsset?
    var childrenAssets = [EveAsset]()

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.is_singleton <- map["is_singleton"]
        self.item_id <- map["item_id"]
        self.location_flag <- map["location_flag"]
        self.location_id <- map["location_id"]
        self.location_type <- map["location_type"]
        self.quantity <- map["quantity"]
        self.type_id <- map["type_id"]
    }
}
