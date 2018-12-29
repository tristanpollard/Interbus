//
// Created by Tristan Pollard on 2018-12-27.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveContactItem: Nameable, EVEImage, Mappable {
    var id: Int64 {
        return self.contact_id
    }
    var name: EveName?
    var imageEndpoint: String {
        return self.name!.getImageEndpoint()
    }
    var imageID: Int64 {
        return self.id
    }
    var imageExtension: String {
        return self.name!.getImageExtension()
    }
    private(set) var placeholder: UIImage = UIImage(named: "characterPlaceholder256.jpg")!

    var contact_id: Int64!
    var contact_type: String!
    var is_blocked: Bool?
    var is_watched: Bool?
    var standing: Double!

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        self.contact_id <- map["contact_id"]
        self.contact_type <- map["contact_type"]
        self.is_blocked <- map["is_blocked"]
        self.is_watched <- map["is_watched"]
        self.standing <- map["standing"]
    }
}
