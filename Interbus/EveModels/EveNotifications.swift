//
// Created by Tristan Pollard on 2018-12-26.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveNotifications {

    unowned var character: EveCharacter
    var notifications: [EveNotificationItem] = []

    init(character: EveCharacter) {
        self.character = character
    }

    func fetchNotifications(completion: @escaping () -> ()) {
        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/v4/characters/\(self.character.id)/notifications/", token: self.character.token) { response in
            if let result = response.result as? [[String: Any]] {
                self.notifications = Mapper<EveNotificationItem>().mapArray(JSONArray: result)
            }
            completion()
        }
    }

}
