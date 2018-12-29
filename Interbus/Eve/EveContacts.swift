//
// Created by Tristan Pollard on 2018-12-27.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveContacts {
    var contacts: [EveContactItem] = []
    var contactLabels: [EveContactLabel] = []
    unowned var character: EveCharacter

    init(character: EveCharacter) {
        self.character = character
    }

    @objc
    func sort() {
        self.contacts.sort {
            if $0.standing == $1.standing {
                if let name0 = $0.name?.name, let name1 = $1.name?.name {
                    return name0 < name1
                }
                return $0.id < $1.id
            }
            return $0.standing! > $1.standing!
        }
    }

    func fetchContactsAndLabels(completion: @escaping () -> ()) {
        let group = DispatchGroup()
        group.enter()
        self.fetchContacts {
            group.leave()
        }

        self.fetchLabels {
            group.leave()
        }

        group.notify(queue: .main) {
            completion()
        }
    }

    func fetchContacts(completion: @escaping () -> ()) {
        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/v2/characters/\(self.character.id)/contacts/", token: self.character.token) { response in
            if let result = response.result as? [[String: Any]] {
                self.contacts = Mapper<EveContactItem>().mapArray(JSONArray: result)
            }
            self.contacts.fetchNames {
                self.sort()
                completion()
            }
        }
    }

    func fetchLabels(completion: @escaping () -> ()) {
        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/v2/characters/\(self.character.id)/contacts/labels/", token: self.character.token) { response in
            if let result = response.result as? [[String: Any]] {
                self.contactLabels = Mapper<EveContactLabel>().mapArray(JSONArray: result)
            }
        }
    }
}
