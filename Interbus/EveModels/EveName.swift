//
// Created by Tristan Pollard on 2018-12-16.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

enum EveNameCategory: String {
    case alliance = "alliance"
    case character = "character"
    case constellation = "constellation"
    case corporation = "corporation"
    case inventory_type = "invetory_type"
    case region = "region"
    case solar_system = "solar_system"
    case stations = "stations"
    case asset = "asset"
}

struct DefaultNameCategoryContext: MapContext {
    var category: EveNameCategory
}

class EveName: Mappable, CustomStringConvertible, CustomDebugStringConvertible {

    var name: String! = ""
    var id: Int64! = -1
    // alliance, character, constellation, corporation, inventory_type, region, solar_system, station
    var category: EveNameCategory!

    var description: String {
        return self.name
    }
    var debugDescription: String {
        return String(self.id) + ":" + self.name
    }

    init(_ id: Int64, name: String, category: EveNameCategory) {
        self.id = id
        self.name = name
        self.category = category
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.name <- map["name"]
        if let defaultNameContext = map.context as? DefaultNameCategoryContext {
            self.category = defaultNameContext.category
            self.id <- map["item_id"]
        } else {
            self.id <- map["id"]
            self.category <- map["category"]
        }
    }

    func getImageEndpoint() -> String {
        switch self.category {
        case .corporation?:
            return "Corporation"
        case .alliance?:
            return "Alliance"
        case .character?:
            return "Character"
        default:
            return "Type"
        }
    }

    func getImageExtension() -> String {
        switch self.category {
        case .character?:
            return "jpg"
        default:
            return "png"
        }
    }
}

extension EveName: Comparable {
    static func <(lhs: EveName, rhs: EveName) -> Bool {
        return lhs.name < rhs.name
    }

    static func ==(lhs: EveName, rhs: EveName) -> Bool {
        return lhs.name == rhs.name
    }
}