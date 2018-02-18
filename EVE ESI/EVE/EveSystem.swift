//
// Created by Tristan Pollard on 2018-02-17.
// Copyright (c) 2018 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveSystem : Nameable, Mappable {

    required init?(map: Map) {

    }

    init (_ system_id : Int64){
        self.system_id = system_id
    }

    func mapping(map: Map) {
        self.star_id <- map["star_id"]
        self.system_id <- map["system_id"]
        self.name <- map["name"]
        self.security_status <- map["security_status"]
        self.security_class <- map["security_class"]
        self.constellation_id <- map["constellation_id"]
    }

    func loadSystem(completionHandler: @escaping() -> ()){
        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/universe/systems/\(self.system_id)/"){ response in
            if let result = response.result as? [String:Any]{
                Mapper<EveSystem>().map(JSON: result, toObject: self)
            }
            completionHandler()
        }
    }

    var id : Int64{
        get{
            return self.system_id!
        }
    }

    var star_id : Int64?
    var system_id : Int64?
    var name = ""
    var security_status : Float?
    var security_class : String?
    var constellation_id : Int64?


}
