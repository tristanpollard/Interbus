//
// Created by Tristan Pollard on 2018-12-16.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

struct MailInboxContext: MapContext {
    var inbox: EveMail
}

class EveMailItem: Mappable {

    unowned var inbox: EveMail

    var from: Int64?
    var is_read: Bool?
    var labels: [Int64]?
    var mail_id: Int64?
    var recipients: [EveMailRecipient]?
    var subject: String?
    var timestamp: Date?
    var sender: EveCharacter?

    var body: String?

    required init?(map: Map) {
        let context = map.context as! MailInboxContext
        self.inbox = context.inbox
    }

    func mapping(map: Map) {
        self.from <- map["from"]
        self.is_read <- map["is_read"]
        self.labels <- map["labels"]
        self.mail_id <- map["mail_id"]
        self.subject <- map["subject"]
        if self.recipients == nil { // Don't overwrite recipients in the event we have fetched their name
            self.recipients <- map["recipients"]
        }
        self.timestamp <- (map["timestamp"], TransformDate())
        self.body <- map["body"]
        if let from = self.from {
            if let sender = self.sender, sender.id == self.from {
                return
            }
            self.sender = EveCharacter(id: from)
        }
    }

    func fetchMail(completion: @escaping (EveMailItem) -> ()) {
        let esi = ESIClient.sharedInstance
        if let id = self.mail_id {
            esi.invoke(endPoint: "/v1/characters/\(self.inbox.character.id)/mail/\(id)", token: self.inbox.character.token) { response in
                if let result = response.result as? [String: Any] {
                    let _ = Mapper<EveMailItem>().map(JSON: result, toObject: self)
                    completion(self)
                }
            }
        }
    }

    func deleteMail(completion: @escaping (Bool) -> ()) {
        let esi = ESIClient.sharedInstance
        if let id = self.mail_id {
            esi.invoke(endPoint: "/v1/characters/\(self.inbox.character.id)/mail/\(id)", httpMethod: .delete, token: self.inbox.character.token) { response in
                if response.statusCode == 204 {
                    self.inbox.mail = self.inbox.mail.filter {
                        $0.mail_id != id
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }

    func markMailRead(completion: @escaping () -> ()) {
        let esi = ESIClient.sharedInstance
    }

    func getBodyString() -> String? {
        guard let bodyStr = self.body else {
            return nil
        }

        return bodyStr.replacingOccurrences(of: "<br />", with: "\n").replacingOccurrences(of: "<br>", with: "\n").replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}

extension Array where Element == EveMailItem {
    func fetchSenders(completion: @escaping () -> ()) {
        let senders: [EveCharacter] = self.compactMap {
            $0.sender
        }
        senders.fetchNames {
            completion()
        }
    }

    func fetchRecipients(completion: @escaping () -> ()) {
        var recipients: [EveMailRecipient] = []
        self.forEach { mail in
            if let recip = mail.recipients?.compactMap({ $0 }) {
                recipients += recip
            }
        }

        recipients.fetchNames {
            completion()
        }
    }
}

class EveMailRecipient: Nameable, Mappable {
    var recipient_id: Int64!
    var recipient_type: String!

    var id: Int64 {
        get {
            return self.recipient_id
        }
    }
    var name: EveName?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.recipient_id <- map["recipient_id"]
        self.recipient_type <- map["recipient_type"]
    }
}