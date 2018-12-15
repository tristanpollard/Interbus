//
// Created by Tristan Pollard on 2018-12-14.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

enum FetchType {
    case character
    case corporation
    case alliance
}

protocol Fetchable {
    var fetchEndpoint: String { get }
    var fetchType: FetchType { get }
}

extension Fetchable {
//    func fetchAndMap(completion: @escaping () -> ()) {
//        let esi = ESIClient.sharedInstance
//        esi.invoke(endPoint: self.fetchEndpoint) { response in
//            if let json = response.result as? [String: Any] {
//                switch self.fetchType {
//                case .character:
//                    Mapper<EveCharacterData>().map(JSON: json, toObject: self)
//                    break
//                case .corporation:
//                    Mapper<EveCorporationData>().map(JSON: json, toObject: self)
//                    break
//                case .alliance:
//                    Mapper<EveAllianceData>().map(JSON: json, toObject: self)
//                default:
//                    break
//                }
//                completion()
//            }
//        }
//    }
}
