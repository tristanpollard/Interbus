//
// Created by Tristan Pollard on 2018-12-30.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveKillMail: Mappable {

    unowned var kills: EveKills

    var attackers: [EveKillMailAttacker] = []

    var killmail_hash: String!
    var killmail_id: Int64!

    var killmail_time: Date?
    var moon_id: Int64?

    var solar_system_id: Int64? {
        didSet {
            if let id = self.solar_system_id {
                self.system = EveSystem(system: id)
            } else {
                self.system = nil
            }
        }
    }
    var system: EveSystem?

    var victim: EveKillVictim!

    var war_id: Int?
    var killmail_time_string: String?

    required init?(map: Map) {
        let context = map.context as! KillContext
        self.kills = context.kills
    }

    func mapping(map: Map) {
        self.killmail_id <- map["killmail_id"]
        if let _ = map.context as? KillContext {
            self.killmail_hash <- map["killmail_hash"]
        } else {
            self.attackers <- map["attackers"]
            self.killmail_time <- (map["killmail_time"], TransformDate())
            self.killmail_time_string <- map["killmail_time"]
            self.moon_id <- map["moon_id"]
            self.solar_system_id <- map["solar_system_id"]
            self.victim <- map["victim"]
            self.war_id <- map["war_id"]
        }
    }

    func fetchKillMailDetails(completion: @escaping () -> ()) {
        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/v1/killmails/\(self.killmail_id!)/\(self.killmail_hash!)/") { response in
            if let result = response.result as? [String: Any] {
                let _ = Mapper<EveKillMail>().map(JSON: result, toObject: self)
            }
            completion()
        }
    }

}

extension Array where Element == EveKillMail {
    func fetchKillMails(completion: @escaping () -> ()) {
        let group = DispatchGroup()
        self.forEach { kill in
            group.enter()
            kill.fetchKillMailDetails {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.fetchNames {
                completion()
            }
        }
    }

    func fetchNames(completion: @escaping () -> ()) {
        let group = DispatchGroup()

        let names: [EveKillVictim] = self.compactMap {
            $0.victim
        }
        group.enter()
        names.fetchNames {
            group.leave()
        }

        var attackers: [EveKillMailAttacker] = []
        attackers += self.flatMap {
            $0.attackers
        }
        group.enter()
        attackers.fetchNames {
            group.leave()
        }

        var ships: [EveType] = self.map {
            $0.victim.ship
        }
        ships += attackers.flatMap {
            $0.ship
        }
        group.enter()
        ships.fetchNames {
            group.leave()
        }

        let systems = self.flatMap {
            $0.system
        }
        group.enter()
        systems.fetchNames {
            group.leave()
        }

        group.notify(queue: .main) {
            completion()
        }
    }
}