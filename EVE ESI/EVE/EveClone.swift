//
// Created by Tristan Pollard on 2017-10-01.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveClone : Mappable{

    class EveImplant : Nameable{

        private(set) var id: Int64 = 0
        var name: String = ""

        init(id: Int64){
            self.id = id
        }

    }

    var implant_ids = [Int64]()
    var implants = [EveImplant]()
    var location_id : Int64?
    var location_type : String?
    var active_clone = false

    var location_name : String?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.implant_ids <- map["implants"]
        self.location_id <- map["location_id"]
        self.location_type <- map["location_type"]

        for ids in implant_ids{
            implants.append(EveImplant(id: ids))
        }
    }

    func loadLocationName(token: SSOToken?, completionHandler: @escaping() -> ()){

        if self.location_type == "structure" && token != nil{
            let loc = EveStructure(self.location_id!)
            loc.loadStructure(token: token!){
                self.location_name = loc.name
                completionHandler()
            }
            return
        }

        let ids = [self.location_id!]
        ids.loadNames{ names in
            self.location_name = names[self.location_id!]
            completionHandler()
        }


    }


}
