//
// Created by Tristan Pollard on 2018-12-30.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

struct KillMailVictimContext: MapContext {
    var killMail: EveKillMail
}

struct KillMailVictimItems: Mappable {
    var flag: Int!
    var item_type_id: Int64!
    var items: [KillMailVictimItems] = []
    var quantity_destroyed: Int64?
    var quantity_dropped: Int64?
    var singleton: Int!

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        self.flag <- map["flag"]
        self.item_type_id <- map["item_type_id"]
        self.items <- map["items"]
        self.quantity_destroyed <- map["quantity_destroyed"]
        self.quantity_dropped <- map["quantity_dropped"]
        self.singleton <- map["singleton"]
    }
}

class EveKillVictim: Mappable, Nameable, EVEImage {

    //unowned var killMail: EveKillMail

    var id: Int64 {
        return self.character_id ?? 0
    }
    var name: EveName?
    private(set) var imageEndpoint: String = "Character"
    var imageID: Int64 {
        return self.id
    }
    private(set) var imageExtension: String = "jpg"
    private(set) var placeholder: UIImage = UIImage(named: "characterPlaceholder128.jpg")!

    var alliance_id: Int64?
    var character_id: Int64?
    var corporation_id: Int64?
    var damage_taken: Int!
    var faction_id: Int64?

    var items: KillMailVictimItems?
    var position: EvePosition!

    var ship_type_id: Int64! {
        didSet {
            self.ship = EveType(id: self.ship_type_id)
        }
    }
    var ship: EveType!

    required init?(map: Map) {
//        let context = map.context as! KillMailVictimContext
//        self.killMail = context.killMail
    }

    func mapping(map: Map) {
        self.alliance_id <- map["alliance_id"]
        self.character_id <- map["character_id"]
        self.corporation_id <- map["corporation_id"]
        self.damage_taken <- map["damage_taken"]
        self.faction_id <- map["faction_id"]
        self.items <- map["items"]
        self.position <- map["position"]
        self.ship_type_id <- map["ship_type_id"]
    }
}
