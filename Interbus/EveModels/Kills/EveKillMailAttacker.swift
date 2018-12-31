//
// Created by Tristan Pollard on 2018-12-30.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

struct KillMailAttackerContext: MapContext {
    var killMail: EveKillMail
}

class EveKillMailAttacker: Mappable, Nameable, EVEImage {

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

    var alliance_id: Int64? {
        didSet {
            if let id = self.alliance_id, id != oldValue {
                self.alliance = EveAllianceData(id: id)
            } else {
                self.alliance = nil
            }
        }
    }
    var alliance: EveAllianceData?
    var character_id: Int64?
    var corporation_id: Int64? {
        didSet {
            if let id = self.corporation_id, id != oldValue {
                self.corporation = EveCorporationData(id: id)
            } else {
                self.corporation = nil
            }
        }
    }
    var corporation: EveCorporationData?
    var damage_done: Int!
    var faction_id: Int64?
    var final_blow: Bool!
    var security_status: Double!

    var ship_type_id: Int64? {
        didSet {
            if let shipId = self.ship_type_id {
                self.ship = EveType(id: shipId)
            } else {
                self.ship = nil
            }
        }
    }
    var ship: EveType?

    var weapon_type_id: Int64? {
        didSet {
            if let weaponId = self.weapon_type_id {
                self.weapon = EveType(id: weaponId)
            } else {
                self.weapon = nil
            }
        }
    }
    var weapon: EveType?

    required init?(map: Map) {
        //let context = map.context as! KillMailAttackerContext
        //self.killMail = context.killMail
    }

    func mapping(map: Map) {
        self.alliance_id <- map["alliance_id"]
        self.character_id <- map["character_id"]
        self.corporation_id <- map["corporation_id"]
        self.damage_done <- map["damage_done"]
        self.faction_id <- map["faction_id"]
        self.final_blow <- map["final_blow"]
        self.security_status <- map["security_status"]
        self.ship_type_id <- map["ship_type_id"]
        self.weapon_type_id <- map["weapon_type_id"]
    }
}
