//
// Created by Tristan Pollard on 2018-12-14.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveCorporationData: Nameable, Mappable, EVEImage {

    var lastUpdate: Date?

    private(set) var imageEndpoint: String = "Corporation"
    var imageID: Int64 {
        get {
            return self.id
        }
    }
    private(set) var imageExtension: String = "png"
    var placeholder: UIImage {
        get {
            return UIImage(named: "corporationPlaceholder256.png")!
        }
    }

    var id: Int64 {
        get {
            return self.corporation_id
        }
    }
    var name: EveName?

    var corporation_id: Int64!

    var alliance_id: Int64? {
        didSet {
            if let id = self.alliance_id, id != oldValue {
                self.alliance = EveAllianceData(id: id)
            }
        }
    }
    var corporation_name: String!
    var ceo_id: Int64?
    var creator_id: Int64?
    var date_founded: Date?
    var description: String?
    var faction_id: Int64?
    var home_station_id: Int64?
    var member_count: Int?
    var shares: Int64?
    var tax_rate: Float?
    var ticker: String?
    var url: String?
    var war_eligible: Bool?

    var alliance: EveAllianceData?

    init(id: Int64) {
        self.corporation_id = id
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.alliance_id <- map["alliance_id"]
        self.ceo_id <- map["ceo_id"]
        self.creator_id <- map["creator_id"]
        self.date_founded <- (map["date_founded"], TransformDate())
        self.description <- map["description"]
        self.faction_id <- map["faction_id"]
        self.home_station_id <- map["home_station_id"]
        self.member_count <- map["member_count"]
        self.shares <- map["shares"]
        self.tax_rate <- map["tax_rate"]
        self.ticker <- map["ticker"]
        self.url <- map["url"]
        self.war_eligible <- map["war_eligible"]
        self.corporation_name <- map["name"]

        self.lastUpdate = Date()
    }

    func fetchCorporationData(completion: @escaping (EveCorporationData) -> ()) {
        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/v4/corporations/\(self.id)") { response in
            if let json = response.result as? [String: Any] {
                Mapper<EveCorporationData>().map(JSON: json, toObject: self)
                completion(self)
            }
        }
    }
}
