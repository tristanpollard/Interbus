//
// Created by Tristan Pollard on 2017-10-04.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import Alamofire

class EveSendMail {

    var approved_cost : Int = 0
    var body : String
    var recipients : [SearchResult]
    var subject : String

    var token : SSOToken

    let esi = ESIClient.sharedInstance

    init(body : String, recipients: [SearchResult], subject : String, token: SSOToken){
        self.body = body
        self.recipients = recipients
        self.subject = subject
        self.token = token
    }

    func send(completionHandler: @escaping(ESIResponse) -> ()){
        let body : [String:Any] = [
            "approved_cost" : self.approved_cost,
            "body" : "<font size=\"12\" color=\"#bfffffff\">\(self.body)</font>",
            "recipients" : self.getAllRecipients(),
            "subject" : self.subject
        ]

        let params : Parameters = body
        debugPrint(params)
        esi.invoke(endPoint: "/characters/\(self.token.character_id!)/mail/", httpMethod: .post, parameters: params, parameterEncoding: JSONEncoding.default, token: self.token){ result in
            completionHandler(result)
        }

    }

    func getAllRecipients() -> [[String:Any]]{

        var recip = [[String:Any]]()
        for recipient in self.recipients{
            recip.append(["recipient_id" : recipient.id, "recipient_type" : recipient.type.rawValue])
        }

        return recip
    }

}
