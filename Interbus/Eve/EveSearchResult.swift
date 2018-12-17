//
// Created by Tristan Pollard on 2018-12-17.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import UIKit

enum EveSearchCategory: String {
    case agent = "agent"
    case alliance = "alliance"
    case character = "character"
    case constellation = "constellation"
    case corporation = "corporation"
    case faction = "faction"
    case inventory_type = "inventory_type"
    case region = "region"
    case solar_system = "solar_system"
    case station = "station"
}

class EveSearchResult: Nameable, EVEImage, Equatable {
    var category: EveSearchCategory
    var search_id: Int64

    var id: Int64 {
        get {
            return self.search_id
        }
    }
    var name: EveName?
    var imageEndpoint: String {
        get {
            switch self.category {
            case .character:
                return "Character"
            case .corporation:
                return "Corporation"
            case .alliance:
                return "Alliance"
            default:
                return "Type"
            }
        }
    }
    var imageID: Int64 {
        get {
            return self.id
        }
    }
    var imageExtension: String {
        get {
            switch self.category {
            case .character:
                return "jpg"
            default:
                return "png"
            }
        }
    }
    var placeholder: UIImage {
        get {
            return UIImage(named: "characterPlaceholder256.jpg")!
        }
    }

    init(_ id: Int64, category: EveSearchCategory) {
        self.search_id = id
        self.category = category
    }

    static func ==(lhs: EveSearchResult, rhs: EveSearchResult) -> Bool {
        return lhs.category == rhs.category && lhs.id == rhs.id
    }

}

extension Array where Element == EveSearchResult {
    func asRecipients() -> [[String: Any]] {
        var recip = [[String: Any]]()
        self.forEach { recipient in
            recip.append(["recipient_id": recipient.id, "recipient_type": recipient.category.rawValue])
        }
        return recip
    }
}
