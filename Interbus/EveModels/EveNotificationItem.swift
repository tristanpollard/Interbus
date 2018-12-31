//
// Created by Tristan Pollard on 2018-12-26.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveNotificationItem: Mappable {

    var is_read: Bool?
    var notification_id: Int64!
    var sender_id: Int64!
    var text: String?
    var timestamp: Date?
    var type: String!

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.is_read <- map["is_read"]
        self.notification_id <- map["notification_id"]
        self.sender_id <- map["sender_id"]
        self.text <- map["text"]
        self.timestamp <- (map["timestamp"], TransformDate())
        self.type <- map["type"]
    }
}
