//
// Created by Tristan Pollard on 2017-10-14.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveMarketOrder : Mappable, Nameable{

    var id: Int64 {
        get{
            return self.type_id!
        }
    }
    var name: String = ""

    var account_id : Int64?
    var duration: Int?
    var escrow: Double?
    var is_buy_order: Bool?
    var is_corp: Bool?
    var issued: Date?
    var location_id: Int64?
    var min_volume: Int?
    var order_id: Int?
    var price: Double?
    var range: String?
    var region_id: Int64?
    var state: String?
    var type_id: Int64?
    var volume_remain: Int?
    var volume_total: Int?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.account_id <- map["account_id"]
        self.duration <- map["duration"]
        self.escrow <- map["escrow"]
        self.is_buy_order <- map["is_buy_order"]
        self.is_corp <- map["is_corp"]
        self.issued <- (map["issued"], TransformDate())
        self.location_id <- map["location_id"]
        self.min_volume <- map["min_volume"]
        self.order_id <- map["order_id"]
        self.price <- map["price"]
        self.range <- map["range"]
        self.region_id <- map["region_id"]
        self.state <- map["state"]
        self.type_id <- map["type_id"]
        self.volume_remain <- map["volume_remain"]
        self.volume_total <- map["volume_total"]
    }

}
