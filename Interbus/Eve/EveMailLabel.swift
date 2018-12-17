//
// Created by Tristan Pollard on 2018-12-16.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveMailLabel: Mappable {

    var color: String?
    var label_id: Int64?
    var name: String?
    var unread_count: Int?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.color <- map["color"]
        self.label_id <- map["label_id"]
        self.name <- map["name"]
        self.unread_count <- map["unread_count"]
    }
}
