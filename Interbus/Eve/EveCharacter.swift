//
// Created by Tristan Pollard on 2018-12-14.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveCharacter: Nameable {

    let esi = ESIClient.sharedInstance

    var id: Int64 {
        get {
            return self.character_id
        }
    }
    var name: String? {
        get {
            return self.character_name
        }
        set {
            self.character_name = newValue!
        }
    }

    var character_id: Int64!
    var character_name: String = ""
    var token: SSOToken?

    var characterData: EveCharacterData?

    var locationOnline: EveLocationOnline?
    var locationShip: EveLocationShip?
    var locationSystem: EveLocationSystem?

    init(id: Int64) {
        self.character_id = id
        self.characterData = EveCharacterData(character: self)
    }

    init(token: SSOToken) {
        self.character_id = token.character_id!
        self.character_name = token.character_name!
        self.token = token
        self.characterData = EveCharacterData(character: self)
    }
}

// Location related
extension EveCharacter {
    func fetchLocationOnline(completion: @escaping (EveLocationOnline) -> ()) {
        let options = [
            "token": self.token
        ]
        self.esi.invoke(endPoint: "/v2/characters/\(self.id)/online/", token: self.token) { response in
            if let result = response.result as? [String: Any] {
                self.locationOnline = EveLocationOnline(character: self, json: result)
                completion(self.locationOnline!)
            }
        }
    }

    func fetchLocationShip(completion: @escaping (EveLocationShip) -> ()) {
        self.esi.invoke(endPoint: "/v1/characters/\(self.id)/ship/", token: self.token) { response in
            if let result = response.result as? [String: Any] {
                self.locationShip = EveLocationShip(character: self, json: result)
                completion(self.locationShip!)
            }
        }
    }

    func fetchLocationSystem(completion: @escaping (EveLocationSystem) -> ()) {
        self.esi.invoke(endPoint: "/v1/characters/\(self.id)/location/", token: self.token) { response in
            if let result = response.result as? [String: Any] {
                self.locationSystem = EveLocationSystem(character: self, json: result)
                completion(self.locationSystem!)
            }
        }
    }
}

extension Array where Element: EveCharacter {
    func fetchAllCharacterData(completion: @escaping () -> ()) {
        let group = DispatchGroup()
        self.forEach { character in
            group.enter()
            character.characterData?.fetchCharacterCorpAllianceData {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion()
        }
    }

    func fetchAllCharacterLocationOnline(completion: @escaping () -> ()) {
        let group = DispatchGroup()
        self.forEach { character in
            group.enter()
            character.fetchLocationOnline { online in
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion()
        }
    }

    func fetchAllCharactersLocationShip(completion: @escaping () -> ()) {
        let group = DispatchGroup()
        self.forEach { character in
            group.enter()
            character.fetchLocationShip { ship in
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion()
        }
    }

    func fetchAllCharactersLocationSystems(completion: @escaping () -> ()) {
        let group = DispatchGroup()
        self.forEach { character in
            group.enter()
            character.fetchLocationSystem { system in
                system.fetchName { name in
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion()
        }
    }
}

extension Array where Element: EveCharacter {
    func refreshTokens(completion: @escaping () -> ()) {
        let group = DispatchGroup()
        self.forEach { character in
            group.enter()
            character.token!.refreshIfNeeded {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion()
        }
    }
}