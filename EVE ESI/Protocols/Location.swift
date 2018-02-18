//
// Created by Tristan Pollard on 2018-02-13.
// Copyright (c) 2018 Sumo. All rights reserved.
//

import Foundation
import Alamofire

protocol Location {

    var location_id : Int64 { get }
    var location_name : String { get set }
    var location_type : String { get }

}

extension Location{

    func loadLocation(completionHandler: @escaping() -> ()) {

        let esi = ESIClient.sharedInstance
        let params : [Int64] = [self.location_id]
        esi.invoke(endPoint: "/universe/names",httpMethod: .post, parameters: params.asParameters(), parameterEncoding: ArrayEncoding()){ result in
            debugPrint(result)
        }

    }

}

extension Array where Element : Location{

    func loadAllLocations(_ token : SSOToken, completionHandler: @escaping() -> ()){

        let stations = self.filter{$0.location_type == "station"}
        let citadels = self.filter{$0.location_type == "other"}

        let group = DispatchGroup()

        let stationIds = stations.map({$0.location_id})
        group.enter()

        stationIds.loadNames(){ names in

            for name in names{
                var station = stations.first{$0.location_id == name.key}
                station?.location_name = name.value
            }

            group.leave()
        }

        let citadelIds = Set(citadels.map({$0.location_id})).map{$0}

        let esi = ESIClient.sharedInstance

        var errors = 0

        for id in citadelIds{
            group.enter()

            esi.invoke(endPoint: "/universe/structures/\(id)", token: token, showErrors: false){ response in

                var citadel = self.first(where: { $0.location_id == id })

                guard citadel != nil else{
                    group.leave()
                    return
                }

                if let result = response.result as? [String:Any] {

                    if let name = result["name"] as? String {
                        citadel!.location_name = name
                    }
                }else{
                    citadel!.location_name = "\(id) - Unknown"
                }

                if let code = response.statusCode{
                    if code == 403{
                        errors += 1
                    }else if code == 420 {
                        errors += 1
                    }
                }

                group.leave()
            }
        }

        group.notify(queue: .main){
            debugPrint("Errors: \(errors)")
            completionHandler()
        }

    }

}