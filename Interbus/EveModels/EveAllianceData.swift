//
// Created by Tristan Pollard on 2018-12-14.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveAllianceData: Nameable, Mappable, EVEImage {

    var lastUpdate: Date?

    private(set) var imageEndpoint: String = "Alliance"
    var imageID: Int64 {
        get {
            return self.id
        }
    }
    private(set) var imageExtension: String = "png"
    var placeholder: UIImage {
        get {
            return UIImage(named: "alliancePlaceholder128.png")!
        }
    }

    var id: Int64 {
        get {
            return self.alliance_id
        }
    }
    var name: EveName?

    var alliance_id: Int64!
    var alliance_name: String!

    var creator_corporation_id: Int64? {
        didSet {
            if let id = self.creator_corporation_id {
                self.creatorCorporation = EveCorporationData(id: id)
            }
        }
    }
    var creator_id: Int64? {
        didSet {
            if let id = self.creator_id {
                self.creator = EveCharacterData(id: id)
            }
        }
    }
    var date_founded: Date?
    var executor_corporation_id: Int64? {
        didSet {
            if let id = self.executor_corporation_id {
                self.executorCorporation = EveCorporationData(id: id)
            }
        }
    }
    var faction_id: Int64?
    var ticker: String?

    var executorCorporation: EveCorporationData?
    var creatorCorporation: EveCorporationData?
    var creator: EveCharacterData?

    init(id: Int64) {
        self.alliance_id = id
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.alliance_name <- map["name"]
        self.creator_corporation_id <- map["creator_corporation_id"]
        self.creator_id <- map["creator_id"]
        self.executor_corporation_id <- map["executor_corporation_id"]
        self.faction_id <- map["faction_id"]
        self.ticker <- map["ticker"]
        self.date_founded <- (map["date_founded"], TransformDate())

        self.lastUpdate = Date()
    }

    func fetchAllianceData(completion: @escaping (EveAllianceData) -> ()) {
        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/v3/alliances/\(self.id)") { response in
            if let json = response.result as? [String: Any] {
                let _ = Mapper<EveAllianceData>().map(JSON: json, toObject: self)
                completion(self)
            }
        }
    }
}
