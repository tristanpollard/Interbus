//
// Created by Tristan Pollard on 2018-12-30.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

struct KillContext: MapContext {
    var kills: EveKills
}

class EveKills {

    unowned var character: EveCharacter

    private(set) var kills: [EveKillMail] = []
    private var pages = 1
    private var nextPage = 1
    private var isFetching = false

    init(character: EveCharacter) {
        self.character = character
    }

    func fetchNextPage(fresh: Bool = false, completion: @escaping (Bool) -> ()) {
        // If we want fresh data fetch the first page
        if fresh {
            self.nextPage = 1
        }
        let initialPage = self.nextPage

        // Make sure we are not fetching data ( or it is fresh )
        guard (self.isFetching == false || fresh) && self.hasNextPage() else {
            completion(false)
            return
        }
        self.isFetching = true

        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/v1/characters/\(self.character.id)/killmails/recent/", token: self.character.token) { response in
            if let result = response.result as? [[String: Any]] {
                if let pages = response.rawResponse.response?.allHeaderFields["x-pages"] as? Int {
                    self.pages = pages
                }
                let killContext = KillContext(kills: self)
                let kills = Mapper<EveKillMail>(context: killContext).mapArray(JSONArray: result)
                kills.fetchKillMails {
                    // Ensure the page we are on is the page we are fetching (ie fresh data).
                    if initialPage == self.nextPage {
                        self.nextPage += 1
                        self.isFetching = false
                        if fresh {
                            self.kills = kills
                        } else {
                            self.kills += kills
                        }
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }

    func hasNextPage() -> Bool {
        return self.nextPage <= self.pages
    }

}
