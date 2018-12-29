//
// Created by Tristan Pollard on 2018-12-16.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveWalletJournal {
    unowned var character: EveCharacter

    var entries: [EveWalletJournalItem] = []

    init(character: EveCharacter) {
        self.character = character
    }

    func fetchJournalEntries(completion: @escaping () -> ()) {
        self.entries.removeAll()
        let esi = ESIClient.sharedInstance
        var page = 1
        var pageCount = 1
        let group = DispatchGroup()
        while page <= pageCount {
            let options = [
                "parameters": ["page": page]
            ]
            group.enter()
            esi.invoke(endPoint: "/v4/characters/\(self.character.id)/wallet/journal", token: character.token, options: options) { response in
                if let result = response.result as? [[String: Any]] {
                    if let pages = response.rawResponse.response?.allHeaderFields["x-pages"] as? Int {
                        pageCount = pages
                    }
                    self.entries += Mapper<EveWalletJournalItem>().mapArray(JSONArray: result)
                }
                group.leave()
            }
            page += 1
        }

        group.notify(queue: .main) {
            self.entries.fetchPartyNames {
                completion()
            }
        }
    }
}
