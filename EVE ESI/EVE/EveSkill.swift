//
// Created by Tristan Pollard on 2017-10-10.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveSkill : Mappable, Nameable {

    var name: String = ""
    var id: Int64 {
        get{
            return self.skill_id!
        }
    }

    var active_skill_level : Int?
    var skill_id : Int64?
    var skillpoints_in_skill : Int?
    var trained_skill_level : Int?


    required init?(map: Map) {

    }

    func mapping(map: Map) {

        self.skill_id <- map["skill_id"]
        self.active_skill_level <- map["active_skill_level"]
        self.skillpoints_in_skill <- map["skillpoints_in_skill"]
        self.trained_skill_level <- map["trained_skill_level"]

    }

}
