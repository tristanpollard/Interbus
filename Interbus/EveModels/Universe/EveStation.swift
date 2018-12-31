//
// Created by Tristan Pollard on 2018-12-31.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveStation: Mappable, Nameable {
    var id: Int64 {
        return self.station_id
    }
    var name: EveName?

    var station_id: Int64!

    var max_dockable_ship_volume: Double!
    var station_name: String! {
        get {
            return self.name?.name ?? "Unknown Location"
        }
        set {
            guard newValue != nil else {
                self.name = nil
                return
            }
            self.name = EveName(self.id, name: newValue, category: .stations)
        }
    }

    var office_rental_cost: Double!
    var owner: Int64?
    var position: EvePosition!
    var race_id: Int64?
    var reprocessing_efficiency: Double?
    var reprocessing_stations_take: Double?
    var services: [String]!
    var system_id: Int64! {
        didSet {
            if self.system_id != oldValue {
                self.system = EveSystem(system: self.system_id)
            }
        }
    }
    var system: EveSystem!
    var type_id: Int64!

    init(station: Int64) {
        self.station_id = station
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.station_id <- map["station_id"]
        self.max_dockable_ship_volume <- map["max_dockable_ship_volume"]
        self.station_name <- map["name"]
        self.office_rental_cost <- map["office_rental_cost"]
        self.owner <- map["owner"]
        self.position <- map["position"]
        self.race_id <- map["race_id"]
        self.reprocessing_efficiency <- map["reprocessing_efficiency"]
        self.reprocessing_stations_take <- map["reprocessing_stations_take"]
        self.services <- map["service"]
        self.system_id <- map["system_id"]
        self.type_id <- map["type_id"]
    }

    func fetchStation(completion: @escaping () -> ()) {
        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/v2/universe/stations/\(self.station_id!)/") { response in
            if let result = response.result as? [String: Any] {
                Mapper<EveStation>().map(JSON: result, toObject: self)
            }
            completion()
        }
    }
}
