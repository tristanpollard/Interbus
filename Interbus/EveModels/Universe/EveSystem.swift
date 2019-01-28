//
// Created by Tristan Pollard on 2018-12-30.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveSystem: Mappable, Nameable {

    var system_id: Int64!
    var id: Int64 {
        return self.system_id
    }
    var name: EveName?

    var constellation_id: Int64!
    var systemName: String {
        get {
            return self.name?.name ?? ""
        }
        set {
            self.name = EveName(self.id, name: newValue, category: .solar_system)
        }
    }
    var planets: [EvePlanet] = []
    var position: EvePosition!
    var security_class: String?
    var security_status: Double!
    var star_id: Int64?
    var stargates: [Int64] = []
    var stations: [Int64] = []

    init(system: Int64) {
        self.system_id = system
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.constellation_id <- map["constellation_id"]
        self.planets <- map["planets"]
        self.position <- map["position"]
        self.security_class <- map["security_class"]
        self.security_status <- map["security_status"]
        self.star_id <- map["star_id"]
        self.stargates <- map["stargates"]
        self.stations <- map["stations"]
        self.system_id <- map["system_id"]
    }

    func fetchSystem(completion: @escaping () -> ()) {
        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/v4/universe/systems/\(self.id)/") { response in
            if let result = response.result as? [String: Any] {
                let _ = Mapper<EveSystem>().map(JSON: result, toObject: self)
            }
            completion()
        }
    }
}
