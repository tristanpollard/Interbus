//
// Created by Tristan Pollard on 2018-12-16.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveWallet: Mappable {
    weak var character: EveCharacter?

    var balance: Double?

    init(character: EveCharacter, json: [String: Any]) {
        self.character = character
        Mapper<EveWallet>().map(JSON: json, toObject: self)
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.balance <- map["balance"]
    }
}
