//
// Created by Tristan Pollard on 2018-12-18.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

enum LocationType: String {
    case station = "station"
    case structure = "structure"
}

class EveClone: Mappable {
    var implants: [Int64] = [] {
        didSet {
            var types: [EveType] = []
            for implant in self.implants {
                types.append(EveType(id: implant))
            }
        }
    }
    var implantTypes: [EveType] = []
    var jump_clone_id: Int64!
    var location_id: Int64!
    var name: String?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.implants <- map["implants"]
        self.jump_clone_id <- map["jump_clone_id"]
        self.location_id <- map["location_id"]
        self.name <- map["name"]
    }
}
