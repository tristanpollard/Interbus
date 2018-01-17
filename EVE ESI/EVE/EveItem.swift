//
// Created by Tristan Pollard on 2017-10-08.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveItem : Mappable, Nameable{

    var id: Int64 {
        get{
            return self.type_id!
        }
    }

    var is_included : Bool?
    var is_singleton : Bool?
    var quantity : Int?
    var record_id : Int?
    var type_id : Int64?

    var name : String = ""

    required init?(map: Map) {

    }

    func mapping(map: Map) {

        self.is_included <- map["is_included"]
        self.is_singleton <- map["is_singleton"]
        self.quantity <- map["quantity"]
        self.record_id <- map["record_id"]
        self.type_id <- map["type_id"]

    }

    func urlForItem(size: Int = 64) -> URL{
        return URL(string: "https://image.eveonline.com/Type/\(self.type_id!)_\(size).png")!
    }
}
