//
// Created by Tristan Pollard on 2017-10-01.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveNotification : Mappable{

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.read <- map["is_read"]
        self.notification_id <- map["notification_id"]
        self.sender_id <- map["notification_id"]
        self.sender_type <- map["sender_type"]
        self.text <- map["text"]
        self.type <- map["timestamp"]
    }

//"is_read": true,
//"notification_id": 1,
//"sender_id": 1000132,
//"sender_type": "corporation",
//"text": "amount: 3731016.4000000004\\nitemID: 1024881021663\\npayout: 1\\n",
//"timestamp": "2017-08-16T10:08:00Z",
//"type": "InsurancePayoutMsg"

    var read : Bool?
    var notification_id : Int64?
    var sender_id : Int64?
    var sender_type : String?
    var text : String?
    var timestamp : Date?
    var type : String?

    init(notification : [String:Any]){
        if let read = notification["is_read"] as? Bool{
            self.read = read
        }

        if let not_id = notification["notification_id"] as? Int64{
            self.notification_id = not_id
        }

        if let send_id = notification["sender_id"] as? Int64{
            self.sender_id = send_id
        }

        if let send_type = notification["sender_type"] as? String{
            self.sender_type = send_type
        }

        if let type = notification["type"] as? String{
            self.type = type
        }
    }


}
