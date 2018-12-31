//
// Created by Tristan Pollard on 2018-12-31.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

struct EvePlanet: Mappable {
    var asteroid_belts: [Int64] = []
    var moons: [Int64] = []
    var planet_id: Int64!

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        self.asteroid_belts <- map["asteroid_belts"]
        self.moons <- map["moons"]
        self.planet_id <- map["planet_id"]
    }
}
