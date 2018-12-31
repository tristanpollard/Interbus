//
// Created by Tristan Pollard on 2018-12-18.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveJumpClone: Mappable {
    var implants: [Int64] = [] {
        didSet {
            var types: [EveType] = []
            for implant in self.implants {
                types.append(EveType(id: implant))
            }
            self.implantTypes = types
        }
    }
    var implantTypes: [EveType] = []
    var jump_clone_id: Int64!
    var location_id: Int64! {
        didSet {
            guard self.location_type != .structure else {
                self.station = nil
                return
            }

            if self.location_id != oldValue {
                self.station = EveStation(station: self.location_id)
            }
        }
    }
    var location_type: LocationType!
    var station: EveStation?
    var name: String?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.implants <- map["implants"]
        self.jump_clone_id <- map["jump_clone_id"]
        self.location_id <- map["location_id"]
        self.location_type <- map["location_type"]
        self.name <- map["name"]
    }
}
