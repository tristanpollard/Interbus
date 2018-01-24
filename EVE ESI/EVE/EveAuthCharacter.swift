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

    var assets = EveAssetList()

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

    var journal = [EveJournalEntry]()

    var kills = [EveKill]()

    var mail = [EveMail]()
    var mailLabels = [EveMailLabel]()

    var miningLedger = EveMiningLedger()

    var orders = [EveMarketOrder]()

    var skills = [EveSkill]()
    var skillQueue = [EveSkillQueue]()
    var total_sp : Int?
    var unallocated_sp : Int?

    var stats = [[String:Any]]()

    init(token: SSOToken){
        self.token = token
        super.init(character_id: token.character_id!)
        self.name = self.token!.character_name!
        self.assets.character = self
        self.miningLedger.character = self
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
            completionHandler()
        }
    }

    func isOnline(completionHandler: @escaping(Bool) -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)/online/", token: self.token){ response in
            if let online = response.result as? Bool{
                completionHandler(online)
                return
            }
            completionHandler(false)
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

        let ids = [contact.contact_id]
        esi.invoke(endPoint: "/characters/\(self.id)/contacts", httpMethod: .delete, parameters: ids.asParameters(), parameterEncoding: ArrayEncoding(), token: self.token){ result in
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

            for kill in killMails{
                debugPrint(kill)
            }

            self.kills = Mapper<EveKill>().mapArray(JSONArray: killMails)
            completionHandler()
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
