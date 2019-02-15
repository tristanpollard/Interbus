//
// Created by Tristan Pollard on 2018-12-16.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

struct MailGroup {
    var date: Date
    var items: [EveMailItem]
}

class EveMail {

    unowned var character: EveCharacter

    var labels: [EveMailLabel] = []
    var mail: [EveMailItem] = []

    var lastMailId = Int64(Int32.max)
    var newestMailId: Int64 = 0
    var hasFetchedAll = false

    var isFetching: Bool = false
    var requestCount = 0

    init(character: EveCharacter) {
        self.character = character
    }

    func fetchNewMail(completion: @escaping () -> ()) {
        self.lastMailId = Int64(Int32.max)
        self.newestMailId = 0
        self.hasFetchedAll = false
        self.isFetching = false
        requestCount += 1

        self.fetchNextPageMail { _ in
            completion()
        }

    }

    func fetchNextPageMail(clear: Bool = false, completion: @escaping (Bool) -> ()) {

        let initialRequestCount = self.requestCount
        let initialMailId = self.lastMailId

        guard self.isFetching == false && self.hasFetchedAll == false else {
            completion(false)
            return
        }

        self.isFetching = true

        let esi = ESIClient.sharedInstance
        let options: [ESIClientOptions: Any] = [
            .parameters: [
                "last_mail_id": self.lastMailId
            ]
        ]
        esi.invoke(endPoint: "/v1/characters/\(self.character.id)/mail", token: self.character.token, options: options) { response in
            if let result = response.result as? [[String: Any]] {
                let inboxContext = MailInboxContext(inbox: self)
                let items = Mapper<EveMailItem>(context: inboxContext).mapArray(JSONArray: result)
                if items.count < 50 {
                    self.hasFetchedAll = true
                }
                self.lastMailId = items.min {
                    $0.mail_id! < $1.mail_id!
                }!.mail_id!

                let group = DispatchGroup()

                group.enter()
                items.fetchSenders {
                    group.leave()
                }

                group.enter()
                items.fetchRecipients {
                    group.leave()
                }

                group.notify(queue: .main) {
                    if initialRequestCount == self.requestCount {
                        if initialMailId == Int64(Int32.max) {
                            self.mail = items
                        } else {
                            self.mail += items
                        }
                        self.isFetching = false
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                self.isFetching = false
                completion(false)
            }
        }
    }

    func fetchMailLabels(completion: @escaping () -> ()) {
        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/v3/characters/\(self.character.id)/mail/labels", token: self.character.token) {
            response in
            if let result = response.result as? [String: Any] {
                if let labels = result["labels"] as? [[String: Any]] {
                    self.labels = Mapper<EveMailLabel>().mapArray(JSONArray: labels)
                }
            }
            completion()
        }
    }

    func sendMail(_ subject: String, body: String, recipients: [EveSearchResult], completion: @escaping () -> () = {
    }) {
        let esi = ESIClient.sharedInstance
        let options: [ESIClientOptions: Any] = [
            .parameters: [
                "body": "<font size=\"12\" color=\"#bfffffff\">\(body)</font>",
                "subject": subject,
                "recipients": recipients.asRecipients()
            ],
            .encoding: JSONEncoding.default
        ]
        esi.invoke(endPoint: "/v1/characters/\(self.character.id)/mail/", httpMethod: .post, token: self.character.token, options: options) {
            response in
            completion()
        }
    }

}
