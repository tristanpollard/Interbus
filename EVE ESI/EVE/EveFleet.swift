//
// Created by Tristan Pollard on 2018-02-16.
// Copyright (c) 2018 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

class EveFleet : Mappable{

    class FleetComposition{

        var id : Int64
        var name : String
        var children: [FleetComposition]?
        var members = [FleetMember]()

        enum Position {
            case Fleet, Wing, Squad
        }

        var position : Position

        init(id: Int64, name: String, squads: [FleetComposition]?, members: [FleetMember], position : Position){
            self.id = id
            self.name = name
            self.children = squads
            self.position = position
            self.members = members
        }

        func hasMembers() -> Bool{

            if self.members.count > 0{
                return true
            }

            if let children = self.children{
                for child in children{
                    if child.hasMembers(){
                        return true
                    }
                }
            }

            return false

        }

        func getAllMembers() -> [FleetMember]{

            var mems : [FleetMember] = []

            if self.members.count > 0{
                mems += self.members
            }

            if let children = self.children{
                for child in children{
                    mems += child.getAllMembers()
                }
            }

            return mems

        }

        func countAllSquads() -> Int{

            var count = 0

            if self.position == .Squad{
                count += 1
            }

            if let children = self.children{
                for child in children{
                    count += child.countAllSquads()
                }
            }

            return count

        }

    }

    class FleetMember : Nameable, Mappable{

        required init?(map: Map) {

        }

        func mapping(map: Map) {

            self.character_id <- map["character_id"]
            self.role <- map["role"]
            self.role_name <- map["role_name"]
            self.ship_type_id <- map["ship_type_id"]
            self.solar_system_id <- map["solar_system_id"]
            self.squad_id <- map["squad_id"]
            self.takes_fleet_warp <- map["takes_fleet_warp"]
            self.wing_id <- map["wing_id"]

            self.ship = EveType(self.ship_type_id!)
            self.system = EveSystem(self.solar_system_id!)

        }

        var id : Int64{
            get{
                return self.character_id!
            }
        }
        var name = ""

        var character_id : Int64?
        var join_time : Date?
        var role : String?
        var role_name : String?

        var ship : EveType?

        var ship_type_id : Int64?

        var system : EveSystem?

        var solar_system_id : Int64?
        var squad_id : Int64?
        var takes_fleet_warp : Bool?
        var wing_id : Int64?

    }

    var expires : Date?

    var character : EveAuthCharacter!
    var fleet_id : Int64?
    var role : String?
    var squad_id : Int64?
    var wing_id : Int64?

    var is_free_move : Bool?
    var is_registered : Bool?
    var is_voice_enabled : Bool?
    var motd : String?

    var composition : FleetComposition? //fleet command

    var members = [FleetMember]()

    let esi = ESIClient.sharedInstance

    var description : String{

        if let id = self.fleet_id{
            return String(id)
        }

        return "Fleet - \(self.character.id)"
    }


    required init?(map: Map) {

    }

    func mapping(map: Map) {

        if let context = (map.context as? ESIContext)?.type {

            if context == "fleet" {
                self.fleet_id <- map["fleet_id"]
                self.role <- map["role"]
                self.squad_id <- map["squad_id"]
                self.wing_id <- map["wing_id"]
            }else if context == "info"{
                self.is_free_move <- map["is_free_move"]
                self.is_registered <- map["is_registered"]
                self.is_voice_enabled <- map["is_voice_enabled"]
                self.motd <- map["motd"]
            }
        }
    }

    init(_ character : EveAuthCharacter){
        self.character = character
    }

    func loadAllShipNames(completionHandler: @escaping() -> ()){

        guard let comp = self.composition else{
            completionHandler()
            return
        }

        let ships = self.members.flatMap({$0.ship})
        ships.loadNames{
            completionHandler()
        }
    }

    func loadAllSystemNames(completionHandler: @escaping() -> ()){

        guard let comp = self.composition else{
            completionHandler()
            return
        }

        let systems = self.members.flatMap({$0.system})
        systems.loadNames{
            completionHandler()
        }
    }

    func parent(comp : FleetComposition) -> FleetComposition?{

        if let fc = self.composition {

            if let wings = fc.children {
                for wing in wings {

                    if wing.id == comp.id{
                        return fc
                    }

                    if let squads = wing.children {
                        for squad in squads {
                            if squad.id == comp.id {
                                return wing
                            }
                        }
                    }
                }
            }

        }

        return nil
    }

    func addWing(fc: FleetComposition, completionHandler: @escaping(Int64) -> ()){

        esi.invoke(endPoint: "/fleets/\(self.fleet_id!)/wings/", httpMethod: .post, token: self.character.token) { response in

            if let result = response.result as? [String:Any]{
                if let wing_id = result["wing_id"] as? Int64{

                    if fc.children == nil{
                        fc.children = [FleetComposition]()
                    }

                    let wingCount = fc.children!.count

                    fc.children!.append(FleetComposition(id: wing_id, name: "Wing \(wingCount + 1)", squads: nil, members: [], position: .Wing))

                    completionHandler(wing_id)
                    return
                }
            }

            completionHandler(-1)

        }

    }

    func addSquad(wing: FleetComposition, completionHandler: @escaping(Int64) -> ()){

        esi.invoke(endPoint: "/fleets/\(self.fleet_id!)/wings/\(wing.id)/squads/", httpMethod: .post, token: self.character.token){ response in

            debugPrint(response.rawResponse)

            if let result = response.result as? [String:Any]{
                if let squad_id = result["squad_id"] as? Int64{

                    if wing.children == nil{
                        wing.children = [FleetComposition]()
                    }

                    let squadCount = wing.children!.count

                    wing.children!.append(FleetComposition(id: squad_id, name: "Squad \(self.composition!.countAllSquads() + 1)", squads: nil, members: [], position: .Squad))

                    completionHandler(squad_id)
                    return
                }
            }

            completionHandler(-1)

        }

    }

    func removeSquad(squad: FleetComposition, completionHandler: @escaping(Bool) -> ()){

        esi.invoke(endPoint: "/fleets/\(self.fleet_id!)/squads/\(squad.id)", httpMethod: .delete, token: self.character.token){ response in

            debugPrint(response.rawResponse)

            if response.statusCode == 204 {

                let parent = self.parent(comp: squad)
                if let index = parent?.children?.index(where: { $0 === squad }) {
                    parent?.children?.remove(at: index)
                    completionHandler(true)
                    return
                }

            }

            completionHandler(false)
        }
    }

    func removeWing(wing: FleetComposition, completionHandler: @escaping(Bool) -> ()){
        esi.invoke(endPoint: "/fleets/\(self.fleet_id!)/wings/\(wing.id)/", httpMethod: .delete, token: self.character.token){ response in

            debugPrint(response.rawResponse)

            if response.statusCode == 204 {

                let parent = self.parent(comp: wing)
                if let index = parent?.children?.index(where: { $0 === wing }) {
                    parent?.children?.remove(at: index)
                    completionHandler(true)
                    return
                }
            }

            completionHandler(false)
        }
    }

    func removeMember(member: FleetMember, completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/fleets/\(self.fleet_id!)/members/\(member.character_id!)/", httpMethod: .delete, token: self.character.token){ response in
            debugPrint(response.result)
            completionHandler()
        }
    }

    func moveMember(member: FleetMember, from: FleetComposition, to: FleetComposition, completionHandler: @escaping() -> ()){

        var keys : Parameters = [String:Any]()

        let parent = self.parent(comp: to)

        switch to.position{

            case .Fleet:
                keys["role"] = "fleet_commander"
                break
            case .Wing:
                keys["role"] = "wing_commander"
                keys["wing_id"] = to.id
                break
            case.Squad:
                keys["role"] = "squad_member"
                keys["wing_id"] = parent!.id
                keys["squad_id"] = to.id
            break

            default:
                completionHandler()
                return
        }


        esi.invoke(endPoint: "/fleets/\(self.fleet_id!)/members/\(member.character_id!)/", httpMethod: .put, parameters: keys, parameterEncoding: JSONEncoding.default, token: self.character.token){ response in

            from.members.remove(at: from.members.index(where: { $0 === member })!)
            to.members.append(member)
            to.members = to.members.sorted(by: {$0.name < $1.name})

            completionHandler()
        }


    }

    func refreshFleet(completionHandler: @escaping(Bool) -> ()){
        esi.invoke(endPoint: "/characters/\(self.character.id)/fleet/", token: self.character.token){ response in

            self.expires = response.expires

            if response.statusCode != 200{
                completionHandler(false)
                return
            }

            if let result = response.result as? [String:Any] {
                Mapper<EveFleet>(context: ESIContext(type: "fleet")).map(JSON: result, toObject: self)
            }

            self.loadMembers{
                self.loadWings{
                    completionHandler(true)
                }
            }

        }
    }

    func loadInfo(completionHandler: @escaping() -> ()){

        guard let id = self.fleet_id else{
            completionHandler()
            return
        }

        esi.invoke(endPoint: "/fleets/\(id)/", token: self.character.token){ response in

            if let result = response.result as? [String:Any]{
                Mapper<EveFleet>(context: ESIContext(type: "info")).map(JSON: result, toObject: self)
            }

            completionHandler()
        }
    }

    func loadMembers(completionHandler: @escaping() -> ()){

        members.removeAll()

        guard let id = self.fleet_id else{
            completionHandler()
            return
        }

        esi.invoke(endPoint: "/fleets/\(id)/members/", token: self.character.token){ response in

            debugPrint(response.result)

            if let result = response.result as? [[String:Any]]{
                self.members = Mapper<FleetMember>().mapArray(JSONArray: result)
                self.members.loadNames{
                    completionHandler()
                }
            }else {
                completionHandler()
            }

        }
    }

    func loadWings(completionHandler: @escaping() -> ()){

        self.composition = nil

        guard let id = self.fleet_id else{
            completionHandler()
            return
        }

        esi.invoke(endPoint: "/fleets/\(id)/wings", token: self.character.token){ response in

            var wingComp = [FleetComposition]()

            if let wings = response.result as? [[String:Any]]{
                for wing in wings {

                    if let id = wing["id"] as? Int64, let name = wing["name"] as? String {

                        var composition = [FleetComposition]()

                        if let squads = wing["squads"] as? [[String: Any]] {
                            for squad in squads{

                                if let squad_id = squad["id"] as? Int64, let squad_name = squad["name"] as? String {

                                    var squadMembers = self.members.filter({$0.squad_id == squad_id}).sorted(by: {$0.name < $1.name})
                                    let s = FleetComposition(id: squad_id, name: squad_name, squads: nil, members: squadMembers, position: .Squad)
                                    composition.append(s)
                                }
                            }
                        }

                        var wingMembers = self.members.filter({$0.wing_id == id && $0.squad_id == -1}).sorted(by: {$0.name < $1.name})
                        composition = composition.sorted(by: {$0.name < $1.name})
                        let w = FleetComposition(id: id, name: name, squads: composition, members: wingMembers, position: .Wing)
                        wingComp.append(w)
                    }
                }
            }

            wingComp = wingComp.sorted(by: {$0.name < $1.name})
            var fcMembers  = [FleetMember]()
            if let fcChar = self.members.first(where: {$0.squad_id == -1 && $0.wing_id == -1}) {
                fcMembers.append(fcChar)
                fcMembers = fcMembers.sorted(by: {$0.name < $1.name})
            }
            let fc = FleetComposition(id: -1, name: "Fleet Command", squads: wingComp, members: fcMembers, position: .Fleet)
            self.composition = fc
            completionHandler()
        }
    }

}
