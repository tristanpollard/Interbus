//
// Created by Tristan Pollard on 2018-12-18.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveType: Mappable, Nameable, EVEImage {
    var id: Int64 {
        get {
            return self.type_id
        }
    }
    var name: EveName?
    var imageEndpoint: String = "Type"
    var imageID: Int64 {
        get {
            return self.id
        }
    }
    var imageExtension: String = "png"
    var placeholder: UIImage = UIImage(named: "corporationPlaceholder256.png")!

    var type_id: Int64!

    init(id: Int64) {
        self.type_id = id
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.type_id <- map["id"]
    }
}
