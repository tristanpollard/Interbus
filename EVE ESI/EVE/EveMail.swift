//
// Created by Tristan Pollard on 2017-10-04.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveMail : Mappable, Equatable{

    var from : EveCharacter?
    var from_id : Int64?
    var labels = [Int]()
    var is_read : Bool?
    var mail_id : Int64?
    var recipients = [EvePlayerOwned]()
    var recipientsData : [[String:Any]]?
    var subject : String?
    var date : Date?
    var body : String?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.from_id <- map["from"]
        self.is_read <- map["is_read"]
        self.labels <- map["labels"]
        self.mail_id <- map["mail_id"]
        self.subject <- map["subject"]
        self.date <- (map["timestamp"], TransformDate())
        self.recipientsData <- map["recipients"]

        self.from = EveCharacter(self.from_id!)
        self.parseRecipients()
    }

    func parseRecipients(){
        for recip in self.recipientsData!{
            if let id = recip["recipient_id"] as? Int64, let type = recip["recipient_type"] as? String{
                switch (type){
                    case "character":
                        self.recipients.append(EveCharacter(id))
                    case "corporation":
                        self.recipients.append(EveCorporation(corporation_id: id))
                    case "alliance":
                        self.recipients.append(EveAlliance(alliance_id: id))
                    default:
                        break
                }
            }
        }
    }

    func loadRecipients(completionHandler: @escaping() -> ()){
        self.recipients.loadNames(){
            completionHandler()
        }
    }

    static func ==(lhs: EveMail, rhs: EveMail) -> Bool {
        return lhs === rhs
    }

    func getBodyString() -> String?{

        guard let bodyStr = self.body else{
            return nil
        }

        return bodyStr.replacingOccurrences(of: "<br />", with: "\n").replacingOccurrences(of: "<br>", with: "\n").replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
