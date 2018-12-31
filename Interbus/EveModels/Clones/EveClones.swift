//
// Created by Tristan Pollard on 2018-12-31.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveClones: Mappable {
    unowned var character: EveCharacter

    var home_location: HomeLocation?
    var jump_clones: [EveJumpClone] = []
    var last_clone_jump_date: Date?
    var last_station_change_date: Date?

    init(character: EveCharacter) {
        self.character = character
    }

    required init?(map: Map) {
        let context = map.context as! CharacterContext
        self.character = context.character
    }

    func mapping(map: Map) {
        self.home_location <- map["home_location"]
        self.jump_clones <- map["jump_clones"]
        self.last_clone_jump_date <- map["last_clone_jump_date"]
        self.last_station_change_date <- map["last_station_change_date"]
    }

    func fetchClones(completion: @escaping () -> ()) {
        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/v3/characters/\(self.character.id)/clones/", token: self.character.token) { response in
            if let result = response.result as? [String: Any] {
                let characterContext = CharacterContext(character: self.character)
                Mapper<EveClones>(context: characterContext).map(JSON: result, toObject: self)
            }
            completion()
        }
    }
}
