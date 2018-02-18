//
// Created by Tristan Pollard on 2017-10-01.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class EveAuthCharacter : EveCharacter{

    required init?(map: Map) {
        super.init(map: map)
        self.fleet = EveFleet(self)
        self.assets = EveAssetList(self)
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        if let context = (map.context as? ESIContext)?.type {

            if context == "fatigue" {

            } else if context == "attributes" {
                self.charisma <- map["charisma"]
                self.intelligence <- map["intelligence"]
                self.memory <- map["memory"]
                self.perception <- map["perception"]
                self.willpower <- map["willpower"]
                self.bonus_remaps <- map["bonus_remaps"]
            }
        }
    }

    struct CharacterLocation : Nameable{
        var solar_system_id : Int64?
        var structure : EveStructure?

        var name = ""
        var id : Int64{
            get{
                return self.solar_system_id!
            }
        }
    }

    struct CharacterActiveShip : Nameable{
        var ship_item_id : Int64?
        var ship_name : String?
        var ship_type_id : Int64?

        var name = ""
        var id : Int64 {
            get{
                return self.ship_type_id!
            }
        }
    }

    var token: SSOToken?

    var fatigue_expire : Date?
    var last_jump : Date?
    var last_jump_update : Date?

    var charisma : Int?
    var intelligence : Int?
    var memory : Int?
    var perception : Int?
    var willpower : Int?
    var bonus_remaps : Int?

    var wallet_balance : Double?

    var assets : EveAssetList!

    var ship : CharacterActiveShip?

    var active_clone : EveClone?{
        get{
            if let clone = clones.first(where: {$0.active_clone == true}){
                return clone
            }
            return nil
        }
    }
    var clones = [EveClone]()

    var contracts = [EveContract]()

    var contacts = [EveContact]()
    var contactLabels = [EveContactLabel]()
    var contacts_last_loaded : Date?

    var fleet : EveFleet!

    var journal = [EveJournalEntry]()

    var kills = [EveKill]()

    var location : CharacterLocation?

    var mail = [EveMail]()
    var mailLabels = [EveMailLabel]()

    var miningLedger = EveMiningLedger()

    var orders = [EveMarketOrder]()

    var last_login : Date?
    var last_logout : Date?
    var logins : Int?
    var online : Bool?

    var skills = [EveSkill]()
    var skillQueue = [EveSkillQueue]()
    var total_sp : Int?
    var unallocated_sp : Int?

    var stats = [[String:Any]]()

    var transactions = [EveTransaction]()

    init(token: SSOToken){
        self.token = token
        super.init(token.character_id!)
        self.name = self.token!.character_name!
        self.miningLedger.character = self
        self.fleet = EveFleet(self)
        self.assets = EveAssetList(self)
    }

    func loadAttributes(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/attributes/", token: self.token){ response in
            if let resp = response.result as? [String:Any]{
                let context = ESIContext(type: "attributes")
                Mapper<EveAuthCharacter>(context: context).map(JSON: resp, toObject: self)
            }
            completionHandler()
        }
    }

    func loadAssets(completionHandler: @escaping() -> ()){
        self.assets.loadAllAssetsForCharacter(){
            self.assets.assetList.loadNames {
                self.assets.processAssets()
                completionHandler()
            }
        }
    }

    func isOnline(completionHandler: @escaping(Bool) -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/online/", token: self.token){ response in

            if let result = response.result as? [String:Any] {

                if let online = result["online"] as? Bool {
                    self.online = online
                    completionHandler(online)
                    return
                }

            }
            completionHandler(false)
        }
    }

    func loadStructure(_ structure_id : Int64, completionHandler: @escaping([Int64 : String]) -> ()){
        esi.invoke(endPoint: "/universe/structures/\(structure_id)", token: self.token, showErrors: false){ response in

            if let structure = response.result as? [String:Any], let name = structure["name"] as? String {
                completionHandler([structure_id : name])
                return
            }

            completionHandler([structure_id:"Unknown"])

        }
    }

    func loadClones(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/clones/", token: self.token){ response in
            if let clones = response.result as? [String:Any]{
                if let jumpClones = clones["jump_clones"] as? [[String:Any]]{
                    self.clones = Mapper<EveClone>().mapArray(JSONArray: jumpClones)
                }
            }
            completionHandler()
        }
    }

    func loadContractItems(contract: EveContract, completionHandler: @escaping(ESIResponse, EveContract) -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/contracts/\(contract.contract_id!)/items/", token: self.token){ response in
            if let items = response.result as? [[String:Any]]{
                contract.items = Mapper<EveItem>().mapArray(JSONArray: items)
                contract.items.loadNames() {
                    completionHandler(response, contract)
                }
            }
        }

    }


    func loadContracts(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/contracts/", token: self.token){ response in
            if let contracts = response.result as? [[String:Any]]{
                self.contracts = Mapper<EveContract>().mapArray(JSONArray: contracts)
                self.contracts = self.contracts.sorted(by: {$0.date_issued! > $1.date_issued!})
            }

            completionHandler()

        }
    }


    func loadContactLabels(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/contacts/labels/", token: self.token){ response in
            if let labels = response.result as? [[String:Any]] {
                self.contactLabels = Mapper<EveContactLabel>().mapArray(JSONArray: labels)
            }
            completionHandler()
        }
    }

    func loadContacts(forceESI : Bool = false, completionHandler: @escaping() -> ()){

        esi.invoke(endPoint: "/characters/\(self.id)/contacts/", token: self.token, forceESI: forceESI){ response in
            if let last_loaded = self.contacts_last_loaded{ //If the user deleted a contact, prevent it from being added back.
                if let expires = response.expires{
                    if last_loaded < expires{
                        completionHandler()
                        return
                    }
                }
            }

            if let contacts = response.result as? [[String:Any]]{
                self.contacts = Mapper<EveContact>().mapArray(JSONArray: contacts)
                self.contacts_last_loaded = Date()
                self.contacts.loadNames(){
                    self.sortContacts()
                    completionHandler()
                }
            }
        }
    }

    func sortContacts(){
        self.contacts = self.contacts.sorted(by: {
            if $0.standing == $1.standing{
                return $0.contact!.name < $1.contact!.name
            }
            return $0.standing! > $1.standing!
        })
    }

    func removeContact(contact: EveContact, completionHandler: @escaping() -> ()){

        let ids : Parameters = ["contact_ids" : contact.contact_id]
        esi.invoke(endPoint: "/characters/\(self.id)/contacts", httpMethod: .delete, parameters: ids , token: self.token){ result in
            self.contacts.remove(at: self.contacts.index(of: contact)!)
            completionHandler()
        }

    }

    func loadFatigue(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/fatigue/", token: self.token) { response in
            if let fatigue = response.result as? [String:String]{

            }
            completionHandler()
        }
    }

    func loadKills(completionHandler: @escaping() -> ()){

        var killMails  = [[String:Any]]()

        let group = DispatchGroup()

        group.enter()
        self.esi.invoke(endPoint: "/characters/\(self.id)/killmails/recent/", token: self.token){ response in

            if let kills = response.result as? [[String:Any]]{
                for kill in kills{
                    if let hash = kill["killmail_hash"] as? String, let id = kill["killmail_id"] as? Int64{
                        group.enter()
                        self.esi.invoke(endPoint: "/killmails/\(id)/\(hash)/"){ response in
                            if let km = response.result as? [String:Any]{
                                group.leave()
                                killMails.append(km)
                            }
                        }

                    }
                }
            }

            group.leave()
        }

        group.notify(queue: .main){
            self.kills = Mapper<EveKill>().mapArray(JSONArray: killMails)
            completionHandler()
        }


    }

    func loadLocation(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/location/", token: self.token){ response in

            var isStructure = false

            let group = DispatchGroup()

            if let result = response.result as? [String:Any] {

                if let system = result["solar_system_id"] as? Int64 {

                    var structure: EveStructure?
                    if let structure_id = result["structure_id"] as? Int64 {
                        isStructure = true
                        structure = EveStructure(structure_id)
                        group.enter()
                        structure!.loadStructure(token: self.token!) {
                            group.leave()
                        }
                    }

                    self.location = CharacterLocation(solar_system_id: system, structure: structure, name: "")
                    group.enter()
                    self.location!.loadName { name in
                        self.location!.name = name
                        group.leave()
                    }


                }

            }

            group.notify(queue: .main) {
                completionHandler()
            }

        }
    }

    func loadShip(completionHandler: @escaping() -> ()){

        esi.invoke(endPoint: "/characters/\(self.id)/ship/", token: self.token){ response in

            let group = DispatchGroup()

            if let result = response.result as? [String:Any]{

                if let item = result["ship_item_id"] as? Int64, let name = result["ship_name"] as? String, let type = result["ship_type_id"] as? Int64{
                    self.ship = CharacterActiveShip(ship_item_id: item, ship_name: name, ship_type_id: type, name: "")
                    group.enter()
                    self.ship!.loadName{ name in
                        self.ship!.name = name
                        group.leave()
                    }
                }

            }

            group.notify(queue: .main){
                completionHandler()
            }

        }

    }

    func loadSkills(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/skills/", token: self.token){ response in

            if let skillJson = response.result as? [String:Any]{
                if let skills = skillJson["skills"] as? [[String:Any]]{
                    self.skills = Mapper<EveSkill>().mapArray(JSONArray: skills)
                }
                if let totalsp = skillJson["total_sp"] as? Int{
                    self.total_sp = totalsp
                }
                if let unallocated = skillJson["unallocated_sp"] as? Int{
                    self.unallocated_sp = unallocated
                }
            }
            self.skills.loadNames() {
                self.skills = self.skills.sorted(by: {$0.name < $1.name})
                completionHandler()
            }
        }
    }

    func loadSkillQueue(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/skillqueue/", token: self.token){ response in
            if let skills = response.result as? [[String:Any]]{
                self.skillQueue = Mapper<EveSkillQueue>().mapArray(JSONArray: skills)
            }

            self.skillQueue.loadNames() {
                self.skillQueue = self.skillQueue.sorted(by: {$0.queue_position! < $1.queue_position!})
                completionHandler()
            }
        }
    }


    func loadMarketOrders(completionHandler: @escaping() -> ()){

        esi.invoke(endPoint: "/characters/\(self.id)/orders/", token: self.token){ response in

            if let orders = response.result as? [[String:Any]]{
                self.orders = Mapper<EveMarketOrder>().mapArray(JSONArray: orders)
                self.orders.loadNames(){
                    completionHandler()
                }
            }
        }


    }

    func loadMailHeaders(lastMailId: Int64?, completionHandler: @escaping() -> ()){

        var params : Parameters?

        if let lastMail = lastMailId {
            params = ["last_mail_id" : lastMail]
        }

        esi.invoke(endPoint: "/characters/\(self.id)/mail/", parameters: params, token: self.token){ response in
            if let mail = response.result as? [[String:Any]]{
                let newMail = Mapper<EveMail>().mapArray(JSONArray: mail)
                newMail.loadAllSenders(){
                    self.mail += newMail
                    completionHandler()
                }
            }
        }
    }

    func loadMailLabels(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/mail/labels/", token: self.token){ response in
            if let labelResponse = response.result as? [String:Any]{
                if let labels = labelResponse["labels"] as? [[String:Any]]{
                    self.mailLabels = Mapper<EveMailLabel>().mapArray(JSONArray: labels)
                }
            }
            completionHandler()
        }
    }

    func loadMail(mail: EveMail, completionHandler: @escaping(ESIResponse) -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/mail/\(mail.mail_id!)", token: self.token){ response in
            if let esiMail = response.result as? [String:Any] {
                mail.body = esiMail["body"] as! String
            }
            completionHandler(response)
        }
    }

    func deleteMail(mail: EveMail, completionHandler: @escaping(Bool) -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/mail/\(mail.mail_id!)/", httpMethod: .delete, token: self.token){ response in
            self.mail.remove(at: self.mail.index(of: mail)!)
            completionHandler(true)
        }
    }

    func loadMining(completionHandler: @escaping() -> ()){
        let params : Parameters = ["page" : 1]
        self.miningLedger.loadAllMiningForCharacter(){
            self.miningLedger.sumMining()
            self.miningLedger.summed.loadNames() {
                completionHandler()
            }
        }
    }

    func loadStats(completionHandler: @escaping() -> ()){

        esi.invoke(endPoint: "/characters/\(self.id)/stats/", token: self.token){ response in

            if let stats = response.result as? [[String:Any]]{
                self.stats = stats
            }

            completionHandler()
        }
    }

    func loadTransactions(completionHandler: @escaping() -> ()){

        esi.invoke(endPoint: "/characters/\(self.id)/wallet/transactions/", token: self.token){ response in

            if let transactions = response.result as? [[String:Any]]{
                self.transactions = Mapper<EveTransaction>().mapArray(JSONArray: transactions)
            }

            completionHandler()

        }

    }

    func loadWalletBalance(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/wallet/", token: self.token){ response in
            if let balance = response.result as? Double {
                self.wallet_balance = balance
            }
            completionHandler()
        }
    }

    func loadWalletJournal(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/wallet/journal/", token: self.token){ response in
            if let resp = response.result as? [[String:Any]] {
                self.journal = Mapper<EveJournalEntry>().mapArray(JSONArray: resp)
            }

            self.journal.loadNames(){ names in
                for entry in self.journal{
                    if let firstID = entry.first_party_id{
                        if let first = names[firstID]{
                            entry.first_party = first
                        }
                    }
                    if let secondID = entry.second_party_id{
                        if let second = names[secondID]{
                            entry.second_party = second
                        }
                    }
                }
                self.journal = self.journal.sorted(by: {$0.date! > $1.date!})
                completionHandler()
            }
        }
    }


}
