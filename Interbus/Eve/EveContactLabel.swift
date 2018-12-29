//
// Created by Tristan Pollard on 2018-12-28.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveContactLabel: Mappable {
    var label_id: String!
    var label_name: String!

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.label_id <- map["label_id"]
        self.label_name <- map["label_name"]
    }
}
