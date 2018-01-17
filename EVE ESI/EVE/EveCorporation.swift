//
// Created by Tristan Pollard on 2017-09-27.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import ObjectMapper

class EveCorporation : EvePlayerOwned, Mappable{

    var creation_date : Date?
    var alliance_id : Int64?
    var ceo_id : Int?
    var creator_id : Int?
    var member_count : Int?
    var tax_rate : Float?
    var ticker : String?
    var url : String?

    var esi = ESIClient.sharedInstance

    var alliance : EveAlliance?

    var corporationDidLoad:(()->Void)?

    var loaded : Bool = false

    init(corporation_id : Int64){
        super.init()
        self.imageEndpoint = "corporation"
        self.id = corporation_id
        self.validImageSizes = [32,64,128,256]
        self.type = .corporation
    }


    required init?(map: Map) {
        super.init()
    }

    func mapping(map: Map) {
        self.name <- map["corporation_name"]
        self.alliance_id <- map["alliance_id"]
        self.ceo_id <- map["ceo_id"]
        self.ticker <- map["ticker"]
        self.tax_rate <- map["tax_rate"]
        self.creator_id <- map["creator_id"]

        if let all_id = self.alliance_id{
            self.alliance = EveAlliance(alliance_id: all_id)
        }
    }

    override func load(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/corporations/\(self.id)") { response in
            if let resp = response.result as? [String:Any] {
                Mapper<EveCorporation>().map(JSON: resp, toObject: self)
            }
            self.corporationDidLoad?()
            completionHandler()
        }
    }


}
