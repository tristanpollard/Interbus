//
// Created by Tristan Pollard on 2018-12-15.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveLocationShip: Mappable, Nameable {
    weak var character: EveCharacter?

    var id: Int64 {
        get {
            return self.ship_type_id!
        }
    }
    var name: EveName?

    var ship_item_id: Int64?
    var ship_name: String?
    var ship_type_id: Int64?

    init(character: EveCharacter, json: [String: Any]) {
        self.character = character
        Mapper<EveLocationShip>().map(JSON: json, toObject: self)
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.ship_item_id <- map["ship_item_id"]
        self.ship_name <- map["ship_name"]
        self.ship_type_id <- map["ship_type_id"]
    }
}
