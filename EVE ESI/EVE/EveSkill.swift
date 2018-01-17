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

    var skill_id : Int64?
    var current_skill_level : Int?
    var skillpoints_in_skill : Int?

    required init?(map: Map) {

    }

    func mapping(map: Map) {

        self.skill_id <- map["skill_id"]
        self.current_skill_level <- map["current_skill_level"]
        self.skillpoints_in_skill <- map["skillpoints_in_skill"]

    }

}
