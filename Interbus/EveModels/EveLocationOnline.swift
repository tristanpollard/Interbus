//
// Created by Tristan Pollard on 2018-12-15.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveLocationOnline: Mappable {
    weak var character: EveCharacter?

    var last_login: Date?
    var last_logout: Date?
    var logins: Int?
    var online: Bool?

    init(character: EveCharacter, json: [String: Any]) {
        self.character = character
        Mapper<EveLocationOnline>().map(JSON: json, toObject: self)
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.last_login <- (map["last_login"], TransformDate())
        self.last_logout <- (map["last_logout"], TransformDate())
        self.logins <- map["logins"]
        self.online <- map["online"]
    }
}
