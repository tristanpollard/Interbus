//
// Created by Tristan Pollard on 2017-10-03.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveJournalEntry : Mappable {

    var amount : Double?
    var balance : Double?
    var date: Date?
    var first_party : EvePlayerOwned?
    var first_party_id : Int64?
    var first_party_type : String?
    var reason : String?
    var ref_id : Int64?
    var ref_type : String?
    var second_party : EvePlayerOwned?
    var second_party_id : Int64?
    var second_party_type : String?
    var tax : Double?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.amount <- map["amount"]
        self.balance <- map["balance"]
        self.date <- (map["date"], TransformDate())
        self.first_party_id <- map["first_party_id"]
        self.first_party_type <- map["first_party_type"]
        self.reason <- map["reason"]
        self.ref_id <- map["ref_id"]
        self.ref_type <- map["ref_type"]
        self.second_party_id <- map["second_party_id"]
        self.second_party_type <- map["second_party_type"]
        self.tax <- map["tax"]
    }
}
