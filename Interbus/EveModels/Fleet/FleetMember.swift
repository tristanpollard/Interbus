import Foundation

class FleetMember: Codable, Nameable {

    var id: Int64 {
        return characterId
    }
    var name: EveName?

    var characterId: Int64
    var joinTime: Date
    var role: String
    var roleName: String
    var shipTypeId: Int64 {
        didSet {
            ship = EveType(id: shipTypeId)
        }
    }
    var ship: EveType?
    var solarSystemId: Int64 {
        didSet {
            system = EveSystem(system: solarSystemId)
        }
    }
    var system: EveSystem?
    var squadId: Int64
    var stationId: Int64?
    var takesFleetWarp: Bool
    var wingId: Int64

    enum CodingKeys: String, CodingKey {
        case characterId = "character_id"
        case joinTime = "join_time"
        case role = "role"
        case roleName = "role_name"
        case shipTypeId = "ship_type_id"
        case solarSystemId = "solar_system_id"
        case squadId = "squad_id"
        case stationId = "station_id"
        case takesFleetWarp = "takes_fleet_warp"
        case wingId = "wing_id"
    }
}