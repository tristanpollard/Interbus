//
// Created by Tristan Pollard on 2017-10-01.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveClone : Mappable{

    var implant_ids : [Int64]?
    var implants : [Int64:String]?
    var location_id : Int64?
    var location_type : String?
    var active_clone = false

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.implant_ids <- map["implants"]
        self.location_id <- map["location_id"]
        self.location_type <- map["location_type"]
    }



}
