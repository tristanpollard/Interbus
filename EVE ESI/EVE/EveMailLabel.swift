//
// Created by Tristan Pollard on 2017-10-06.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import ObjectMapper
import Foundation

class EveMailLabel : Mappable{

    var label_id : Int?
    var color : String?
    var name : String?
    var unread_count : Int?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.label_id <- map["label_id"]
        self.color <- map["color_hex"]
        self.name <- map["name"]
        self.unread_count <- map["unread_count"]
    }

}
