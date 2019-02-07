//
// Created by Tristan Pollard on 2018-12-29.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class FleetDetails: Mappable, Codable {
    var isFreeMove: Bool!
    var isRegistered: Bool!
    var isVoiceEnabled: Bool!
    var motd: String!

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.isFreeMove <- map["is_free_move"]
        self.isRegistered <- map["is_registered"]
        self.isVoiceEnabled <- map["is_voice_enabled"]
        self.motd <- map["motd"]
    }

    enum CodingKeys: String, CodingKey {
        case isFreeMove = "is_free_move"
        case isRegistered = "is_registered"
        case isVoiceEnabled = "is_voice_enabled"
        case motd
    }
}
