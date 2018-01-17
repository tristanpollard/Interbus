//
// Created by Tristan Pollard on 2017-10-10.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveSkillQueue : Mappable, Nameable {

    var skill_id : Int64?
    var queue_position : Int?
    var finished_level : Int?
    var start_date : Date?
    var finish_date : Date?

    var name: String = ""
    var id: Int64 {
        get{
            return self.skill_id!
        }
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {

        self.skill_id <- map["skill_id"]
        self.queue_position <- map["queue_position"]
        self.finished_level <- map["finished_level"]
        self.start_date <- (map["start_date"], TransformDate())
        self.finish_date <- (map["finish_date"], TransformDate())

    }

}
