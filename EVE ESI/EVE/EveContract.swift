//
// Created by Tristan Pollard on 2017-10-01.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveContract : Mappable{

    var assignee : EvePlayerOwned?
    var issuer : EvePlayerOwned?

    var acceptor_id : Int64?
    var assignee_id : Int64?
    var availability : String?
    var collateral : Double?
    var contract_id : Int64?
    var date_accepted : Date?
    var date_completed : Date?
    var date_expired : Date?
    var date_issued : Date?
    var days_to_complete : Int?
    var end_location_id : Int64?
    var for_corporation : Bool?
    var issuer_corporation_id : Int64?
    var issuer_id : Int64?
    var price : Double?
    var reward : Double?
    var start_location_id : Int64?
    var status : String?
    var title : String?
    var type : String?
    var volume : Double?

    var items = [EveItem]()

    required init?(map: Map) {

    }

    func mapping(map: Map) {

        self.acceptor_id <- map["acceptor_id"]
        self.assignee_id <- map["assignee_id"]
        self.availability <- map["availability"]
        self.collateral <- map["collateral"]
        self.contract_id <- map["contract_id"]
        self.days_to_complete <- map["days_to_complete"]
        self.end_location_id <- map["end_location_id"]
        self.for_corporation <- map["for_corporation"]
        self.issuer_corporation_id <- map["issuer_corporation_id"]
        self.issuer_id <- map["issuer_id"]
        self.price <- map["price"]
        self.reward <- map["reward"]
        self.start_location_id <- map["start_location_id"]
        self.status <- map["status"]
        self.title <- map["title"]
        self.type <- map["type"]
        self.volume <- map["volume"]

        self.date_issued <- (map["date_issued"], TransformDate())
        self.date_accepted <- (map["date_accepted"], TransformDate())
        self.date_expired <- (map["date_expired"], TransformDate())

        if self.for_corporation!{
            self.assignee = EveCorporation(corporation_id: self.assignee_id!)
        }else{
            self.assignee = EveCharacter(self.assignee_id!)
        }

        if self.issuer_id == self.issuer_corporation_id{
            self.issuer = EveCorporation(corporation_id: self.issuer_id!)
        }else{
            self.issuer = EveCharacter(self.issuer_id!)
        }

    }

    func loadAssigneeIssuer(completionHandler: @escaping() -> ()){
        let group = DispatchGroup()

        group.enter()
        self.issuer?.load(){
            group.leave()
        }

        group.enter()
        self.assignee?.load(){
            group.leave()
        }

        group.notify(queue: .main) {
            completionHandler()
        }

    }


}
