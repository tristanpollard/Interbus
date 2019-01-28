//
// Created by Tristan Pollard on 2018-12-14.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveCharacterData: Mappable, EVEImage {
    weak var character: EveCharacter?
    var lastUpdate: Date?

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


    var alliance_id: Int64? {
        get {
            return self.corporation?.alliance_id
        }
        set {
            self.corporation?.alliance_id = newValue
        }
    }
    var ancestry_id: Int64?
    var birthday: Date?
    var bloodline_id: Int64?
    var corporation_id: Int64? {
        didSet {
            if let id = self.corporation_id {
                self.corporation = EveCorporationData(id: id)
            }
        }
    }
    var description: String?
    var faction_id: Int64?
    var gender: String?
    var name: String?
    var race_id: Int64?
    var security_stats: Float?

    var corporation: EveCorporationData?
    var alliance: EveAllianceData? {
        get {
            return self.corporation?.alliance
        }
        set {
            self.corporation?.alliance = newValue
        }
    }

    private var _id: Int64!
    var id: Int64 {
        get {
            if let character = self.character {
                return character.id
            }
            return self._id
        }
        set {
            self._id = newValue
        }
    }

    init(character: EveCharacter) {
        self.character = character
    }

    init(id: Int64) {
        self.id = id
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.ancestry_id <- map["ancestry_id"]
        self.birthday <- (map["birthday"], TransformDate())
        self.bloodline_id <- map["bloodline_id"]
        self.corporation_id <- map["corporation_id"]
        self.description <- map["description"]
        self.faction_id <- map["faction_id"]
        self.gender <- map["gender"]
        self.name <- map["name"]
        self.race_id <- map["race_id"]
        self.security_stats <- map["security_status"]
        self.alliance_id <- map["alliance_id"]
        self.lastUpdate = Date()
    }

    func fetchCharacterData(completion: @escaping (EveCharacterData) -> ()) {
        let esi = ESIClient.sharedInstance
        guard self.character != nil else {
            return
        }

        esi.invoke(endPoint: "/v4/characters/\(self.id)") { response in
            if let json = response.result as? [String: Any] {
                let _ = Mapper<EveCharacterData>().map(JSON: json, toObject: self)
                completion(self)
            }
        }
    }

    func fetchCharacterCorpAllianceData(completion: @escaping () -> ()) {
        let group = DispatchGroup()
        group.enter()
        self.fetchCharacterData { data in
            if self.corporation != nil {
                group.enter()
                self.corporation?.fetchCorporationData { corp in
                    group.leave()
                }
            }
            if self.alliance != nil {
                group.enter()
                self.alliance?.fetchAllianceData { alliance in
                    group.leave()
                }
            }
            group.leave()
        }

        group.notify(queue: .main) {
            completion()
        }
    }
}

extension Array where Element: EveCharacterData {
    func fetchAllData(completion: @escaping () -> ()) {
        let group = DispatchGroup()
        self.forEach { character in
            group.enter()
            character.fetchCharacterCorpAllianceData {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion()
        }
    }
}
