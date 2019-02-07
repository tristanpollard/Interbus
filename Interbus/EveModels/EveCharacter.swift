//
// Created by Tristan Pollard on 2018-12-14.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveCharacter: Nameable, EVEImage, Equatable {

    let esi = ESIClient.sharedInstance

    private(set) var imageEndpoint: String = "Character"
    var imageID: Int64 {
        get {
            return self.id
        }
    }
    private(set) var imageExtension: String = "jpg"
    var placeholder: UIImage {
        get {
            return UIImage(named: "characterPlaceholder256.jpg")!
        }
    }
    var id: Int64 {
        get {
            return self.character_id
        }
    }
    var name: EveName?

    var assets: EveAssets!

    var clones: EveClones!

    var character_id: Int64!
    var character_name: String = ""
    var token: SSOToken?

    var characterData: EveCharacterData!

    var contacts: EveContacts!

    var fleet: Fleet?

    var kills: EveKills!

    var locationOnline: EveLocationOnline?
    var locationShip: EveLocationShip?
    var locationSystem: EveLocationSystem?

    var mail: EveMail!

    var notifications: EveNotifications!

    var wallet: EveWallet?
    var walletJournal: EveWalletJournal!

    init(id: Int64) {
        self.character_id = id
        self.characterData = EveCharacterData(character: self)
        self.walletJournal = EveWalletJournal(character: self)
        self.mail = EveMail(character: self)
        self.notifications = EveNotifications(character: self)
        self.contacts = EveContacts(character: self)
        self.assets = EveAssets(character: self)
        self.kills = EveKills(character: self)
        self.clones = EveClones(character: self)
    }

    init(token: SSOToken) {
        self.character_id = token.character_id!
        self.character_name = token.character_name!
        self.token = token
        self.characterData = EveCharacterData(character: self)
        self.walletJournal = EveWalletJournal(character: self)
        self.mail = EveMail(character: self)
        self.notifications = EveNotifications(character: self)
        self.contacts = EveContacts(character: self)
        self.assets = EveAssets(character: self)
        self.kills = EveKills(character: self)
        self.clones = EveClones(character: self)
    }

    static func ==(lhs: EveCharacter, rhs: EveCharacter) -> Bool {
        return lhs.id == rhs.id
    }
}

// Location related
extension EveCharacter {
    func fetchLocationOnline(completion: @escaping (EveLocationOnline) -> ()) {
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


// Wallet
extension EveCharacter {
    func fetchWalletBalance(completion: @escaping (EveWallet) -> ()) {
        self.esi.invoke(endPoint: "/v1/characters/\(self.id)/wallet", token: self.token) { response in
            if let result = response.result as? [String: Any] {
                self.wallet = EveWallet(character: self, json: result)
                completion(self.wallet!)
            }
        }
    }
}

// Fleet
extension EveCharacter {
    func fetchFleet(completion: @escaping (Fleet?) -> ()) {
        self.fleet = nil
        self.esi.invoke(endPoint: "/v1/characters/\(self.id)/fleet/", token: self.token) { response in
            if let result = response.result as? [String: Any] {
                let context = CharacterContext(character: self)
                self.fleet = Mapper<Fleet>(context: context).map(JSON: result)
                if self.fleet?.fleetId == nil {
                    self.fleet = nil
                }
            }
            completion(self.fleet)
        }
    }
}

extension Array where Element: EveCharacter {
    func fetchAllCharacterData(completion: @escaping () -> ()) {
        let group = DispatchGroup()
        self.forEach { character in
            group.enter()
            character.characterData.fetchCharacterCorpAllianceData {
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