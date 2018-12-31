//
// Created by Tristan Pollard on 2018-12-29.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

struct CharacterContext: MapContext {
    var character: EveCharacter
}

class EveFleet: Mappable {

    unowned var character: EveCharacter

    var validFleet: Bool {
        return self.fleet_id != nil
    }

    var fleet_id: Int64?
    var role: String?
    var squad_id: Int64?
    var wing_id: Int64?

    var details: EveFleetDetails?

    required init?(map: Map) {
        let charContext = map.context as! CharacterContext
        self.character = charContext.character
    }

    func mapping(map: Map) {
        self.fleet_id <- map["fleet_id"]
        self.role <- map["role"]
        self.squad_id <- map["squad_id"]
        self.wing_id <- map["wing_id"]
    }

}
