//
// Created by Tristan Pollard on 2018-12-30.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

struct EvePosition: Mappable {
    var x: Double?
    var y: Double?
    var z: Double?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        self.x <- map["x"]
        self.y <- map["y"]
        self.z <- map["z"]
    }
}
