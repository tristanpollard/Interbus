//
// Created by Tristan Pollard on 2017-09-26.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import ObjectMapper

class EveCharacter : EvePlayerOwned, Mappable{

    required init?(map: Map) {
        super.init()
    }

    func mapping(map: Map) {
        if let context = (map.context as? ESIContext)?.type {
            if context == "character" {
                self.name <- map["name"]
                self.corporation_id <- map["corporation_id"]
                self.alliance_id <- map["alliance_id"]
            }
        }
    }

    var corporation_id : Int64?
    var alliance_id : Int64?
    var gender : String?
    var ancestry_id : Int?
    var bloodline_id : Int?
    var race_id : Int?
    var security_status : Double?
    var birthday : Date?

    var corporation : EveCorporation?

    var alliance : EveAlliance?{
        get {
            return self.corporation?.alliance
        }
    }

    var esi = ESIClient.sharedInstance

    var characterImage : UIImage?

    var characterDidLoad:(()->Void)?

    static var validImageSizes = [32,64,128,256,512]

    init(_ character_id: Int64){
        super.init()
        self.imageEndpoint = "character"
        self.imageExtension = "jpg"
        self.id = character_id
        self.type = .character
    }


    override func load(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/characters/\(self.id)") { response in
            if let resp = response.result as? [String:Any] {
                let context = ESIContext(type: "character")
                Mapper<EveCharacter>(context: context).map(JSON: resp, toObject: self)
                self.corporation = EveCorporation(corporation_id: self.corporation_id!)
            }
            completionHandler()
        }
    }

    override func getPlaceholder(size: Int) -> UIImage {
        return super.getPlaceholder(size: size).af_imageRoundedIntoCircle()
    }
}
