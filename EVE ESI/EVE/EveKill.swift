//
// Created by Tristan Pollard on 2018-01-24.
// Copyright (c) 2018 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveKill : Mappable{

    var killmail_id : Int64?
    var killmail_time : Date?

    var attackers : [[String:Double]]?

    var solar_system_id : Int64?

    var victim : [String:Any]?


    required init?(map: Map){

    }

    func mapping(map: Map){

        self.killmail_id <- map["killmail_id"]
        self.attackers <- map["attackers"]
        self.victim <- map["victim"]

    }


}
