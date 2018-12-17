//
// Created by Tristan Pollard on 2018-12-16.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import UIKit

class EveWalletJournalItemParty: Nameable, EVEImage {
    var id: Int64
    var name: EveName? = nil

    var imageEndpoint: String {
        get {
            guard let name = name else {
                return ""
            }
            return name.getImageEndpoint()
        }
    }
    var imageID: Int64 {
        get {
            return self.id
        }
    }
    var imageExtension: String {
        get {
            guard let name = name else {
                return "png"
            }
            return name.getImageExtension()
        }
    }
    var placeholder: UIImage {
        get {
            return UIImage(named: "characterPlaceholder256.jpg")!
        }
    }

    init(id: Int64) {
        self.id = id
    }
}
