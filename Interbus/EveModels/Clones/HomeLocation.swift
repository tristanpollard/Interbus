//
// Created by Tristan Pollard on 2018-12-31.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

struct HomeLocation: Mappable {
    var location_id: Int64?
    var location_type: LocationType?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        self.location_id <- map["location_id"]
        self.location_type <- map["location-type"]
    }
}