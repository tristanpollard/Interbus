//
// Created by Tristan Pollard on 2018-12-29.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveFleetDetails: Mappable {
    var is_free_move: Bool!
    var is_registered: Bool!
    var is_voice_enabled: Bool!
    var motd: String!

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.is_free_move <- map["is_free_move"]
        self.is_registered <- map["is_registered"]
        self.is_voice_enabled <- map["is_voice_enabled"]
        self.motd <- map["motd"]
    }
}
