//
// Created by Tristan Pollard on 2017-10-07.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveContactLabel : Mappable{

    var label_id: Int?
    var label_name: String?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.label_id <- map["label_id"]
        self.label_name <- map["label_name"]
    }
}