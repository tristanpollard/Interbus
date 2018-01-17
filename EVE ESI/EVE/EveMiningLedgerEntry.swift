//
// Created by Tristan Pollard on 2017-12-18.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveMiningLedgerEntry : Nameable, Mappable{

    var id: Int64 {
        get{
            return self.type_id!
        }
    }

    var type_id : Int64!
    var quantity : Int64!
    var date : Date!
    var systemId : Int64!
    var name : String = ""

    required init?(map: Map) {

    }

    init(type_id: Int64){
        self.type_id = type_id
        self.quantity = 0
        self.systemId = 0
        self.date = Date()
    }

    func mapping(map: Map) {

        self.type_id <- map["type_id"]
        self.quantity <- map["quantity"]
        self.systemId <- map["solar_system_id"]
        self.date <- (map["date"], TransformDate())

    }

}
