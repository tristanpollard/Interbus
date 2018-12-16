//
// Created by Tristan Pollard on 2018-12-15.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveLocationSystem: Mappable, Nameable {
    weak var character: EveCharacter?

    var id: Int64 {
        get {
            return self.solar_system_id!
        }
    }
    var name: EveName?

    var solar_system_id: Int64?
    var station_id: Int64?
    var structure_id: Int64?

    init(character: EveCharacter, json: [String: Any]) {
        self.character = character
        Mapper<EveLocationSystem>().map(JSON: json, toObject: self)
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.solar_system_id <- map["solar_system_id"]
        self.station_id <- map["station_id"]
        self.structure_id <- map["structure_id"]
    }
}
