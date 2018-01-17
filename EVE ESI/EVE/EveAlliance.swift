//
// Created by Tristan Pollard on 2017-09-27.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import ObjectMapper

class EveAlliance : EvePlayerOwned, Mappable{

    required init?(map: Map) {
        super.init()
    }

    func mapping(map: Map){
        self.name <- map["alliance_name"]
        self.executor_corp <- map["executor_corp"]
        self.ticker <- map["ticker"]
    }

    var date_founded : Date?
    var executor_corp : Int?
    var ticker : String?

    var allianceDidLoad:(()->Void)?

    var esi = ESIClient.sharedInstance

    var loaded : Bool = false

    var corporations : [EveCorporation]?

    init(alliance_id : Int64){
        super.init()
        self.imageEndpoint = "alliance"
        self.id = alliance_id
        self.type = .alliance
        self.validImageSizes = [32,64,128,256]
    }

    override func load(completionHandler: @escaping() -> ()){
        esi.invoke(endPoint: "/alliances/\(self.id)") { response in
            if let resp = response.result as? [String: Any] {
                let context = ESIContext(type: "alliance")
                Mapper(context: context).map(JSON: resp, toObject: self)
            }
            self.loadAllianceCorporations() {
                completionHandler()
            }
        }
    }

    func loadAllianceCorporations(force : Bool = false, completionHandler: @escaping() -> ()){
        if corporations == nil || force{
            self.corporations = [EveCorporation]()
            esi.invoke(endPoint: "/alliances/\(self.id)/corporations") { response in

                if let corps = response.result as? [Int64] {
                    for corp in corps {
                        self.corporations?.append(EveCorporation(corporation_id: corp))
                    }
                }

                self.corporations!.loadNames(){
                    self.corporations = self.corporations!.sorted(by: {$0.name < $1.name})
                    completionHandler()
                }
            }
        }else{
            completionHandler()
        }
    }

    static func imageURL(alliance_id: Int64, size: Int) -> URL{
        var imageSize = size
        let validImageSizes = [32,64,128,256]
        if validImageSizes.contains(size){
            imageSize = 128
        }

        return URL(string: "https://image.eveonline.com/Alliance/\(alliance_id)_\(imageSize).png")!
    }


}
