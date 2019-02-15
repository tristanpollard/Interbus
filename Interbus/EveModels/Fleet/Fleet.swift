import Foundation
import ObjectMapper
import Alamofire

struct CharacterContext: MapContext {
    var character: EveCharacter
}

class FleetStructure: Codable {
    var id: Int64
    var name: String
    var squads: [FleetStructure]?
    var members: [FleetMember] = []
    var commander: FleetMember?
    weak var parent: FleetStructure?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case squads
    }
}

class Fleet: Mappable {

    unowned var character: EveCharacter

    var validFleet: Bool {
        return self.fleetId != nil
    }

    var fleetId: Int64?
    var role: String?
    var squadId: Int64?
    var wingId: Int64?

    var details: FleetDetails?

    var commander: FleetMember?
    var composition: [FleetStructure] = [] {
        didSet {
            compositionMap = mapComposition()
        }
    }
    var compositionMap: [FleetStructure] = []

    private func mapComposition() -> [FleetStructure] {
        var structure: [FleetStructure] = []
        for wing in composition {
            structure.append(wing)
            if let squads = wing.squads {
                for squad in squads {
                    squad.parent = wing
                    structure.append(squad)
                }
            }
        }
        return structure
    }

    var members: [FleetMember] = []

    required init?(map: Map) {
        let charContext = map.context as! CharacterContext
        self.character = charContext.character
    }

    func mapping(map: Map) {
        self.fleetId <- map["fleet_id"]
        self.role <- map["role"]
        self.squadId <- map["squad_id"]
        self.wingId <- map["wing_id"]
    }

    func fetchComposition(completion: @escaping () -> ()) {
        let esi = ESIClient.sharedInstance
        if let fleetId = fleetId, let token = character.token {
            esi.invoke(endPoint: "/v1/fleets/\(fleetId)/wings/", token: token) { response in
                if let result = response.rawResponse.data {
                    if let composition = try? JSONDecoder().decode([FleetStructure].self, from: result) {
                        self.composition = composition
                    }
                }
                completion()
            }
        }
    }

    func fetchMembers(completion: @escaping () -> ()) {
        let esi = ESIClient.sharedInstance
        if let fleetId = fleetId, let token = character.token {
            esi.invoke(endPoint: "/v1/fleets/\(fleetId)/members/", token: token) { response in
                if let data = response.rawResponse.data {
                    let decoder = JSONDecoder()
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    decoder.dateDecodingStrategy = .formatted(df)
                    if let members = try? decoder.decode([FleetMember].self, from: data) {
                        self.members = members
                    }
                }
                completion()
            }
        }
    }

    func moveMember(member: FleetMember, destination: FleetStructure?, completion: @escaping (Bool) -> ()) {
        let esi = ESIClient.sharedInstance
        if let fleetId = fleetId, let token = character.token {
            var params: [String: Any] = [
                "role": "fleet_commander",
            ]
            var movement: [String: Int64] = [:]

            if let destination = destination {
                if let parent = destination.parent {
                    movement["squad_id"] = destination.id
                    movement["wing_id"] = parent.id
                    params["role"] = "squad_member"
                } else {
                    movement["wing_id"] = destination.id
                    params["role"] = "wing_commander"
                }
            }
            params["movement"] = movement

            let options: [ESIClientOptions: Any] = [
                .parameters: params,
                .encoding: JSONEncoding.default
            ]

            print(options)

            esi.invoke(endPoint: "/v1/fleets/\(fleetId)/members/\(member.id)/", httpMethod: .put, token: token, options: options) { response in
                if response.statusCode == 204 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }

    func removeMember(member: FleetMember, completion: @escaping (Bool) -> ()) {
        let esi = ESIClient.sharedInstance
        if let fleetId = fleetId, let token = character.token {
            esi.invoke(endPoint: "/v1/fleets/\(fleetId)/members/\(member.id)", httpMethod: .delete, token: token) { response in
                if response.statusCode == 204 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }

    func renameStructure(structure: FleetStructure, name: String, completion: @escaping (Bool) -> ()) {
        let esi = ESIClient.sharedInstance
        if let fleetId = fleetId, let token = character.token {
            var endpoint: String = ""
            if structure.squads != nil { // Wing
                endpoint = "/v1/fleets\(fleetId)/wings/\(structure.id)/"
            } else {
                endpoint = "/v1/fleets/\(fleetId)/squads/\(structure.id)/"
            }
            let options: [ESIClientOptions: Any] = [
                .parameters: [
                    "name": name
                ],
                .encoding: JSONEncoding.default
            ]
            esi.invoke(endPoint: endpoint, httpMethod: .put, token: token, options: options) { response in
                var success = false
                if response.statusCode == 204 {
                    success = true
                }
                completion(success)
            }
        }
    }

    func deleteStructure(structure: FleetStructure, completion: @escaping (Bool) -> ()) {
        let esi = ESIClient.sharedInstance
        if let fleetId = fleetId, let token = character.token {
            var endpoint: String = ""
            if structure.squads != nil { // Wing
                endpoint = "/v1/fleets\(fleetId)/wings/\(structure.id)/"
            } else {
                endpoint = "/v1/fleets/\(fleetId)/squads/\(structure.id)/"
            }
            esi.invoke(endPoint: endpoint, httpMethod: .delete, token: token) { response in
                var success = false
                if response.statusCode == 204 {
                    success = true
                }
                completion(success)
            }
        }
    }

    func mapMembers() {
        var compToMember: [Int64: [FleetMember]] = [:]
        commander = nil

        for member in members {
            guard member.squadId != -1 || member.wingId != -1 else { // if both are -1 they are the FC
                commander = member
                continue
            }

            if compToMember[member.squadId == -1 ? member.wingId : member.squadId] != nil {
                compToMember[member.squadId == -1 ? member.wingId : member.squadId]?.append(member)
            } else {
                compToMember[member.squadId == -1 ? member.wingId : member.squadId] = [member]
            }
        }
        2
        for wing in composition {
            wing.members = compToMember[wing.id] ?? []
            if let squads = wing.squads {
                for squad in squads {
                    squad.members = compToMember[squad.id] ?? []
                }
            }
        }
    }


    private(set) var isRefreshing: Bool = false

    @objc
    func refreshFleet(completion: @escaping () -> ()) {
        if isRefreshing {
            return
        }
        isRefreshing = true

        let group = DispatchGroup()
        group.enter()
        fetchMembers {
            group.leave()
        }

        group.enter()
        fetchComposition {
            group.leave()
        }


    }
}
