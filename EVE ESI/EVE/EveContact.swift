//
// Created by Tristan Pollard on 2017-10-02.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Foundation
import ObjectMapper

class EveContact : Mappable, Equatable, Nameable{

    static func ==(lhs: EveContact, rhs: EveContact) -> Bool {
        return lhs === rhs
    }

    enum ContactType : String{
        case alliance, corporation, character, unknown
    }

    var name: String {
        get{
            return self.contact!.name
        }
        set{
            self.contact?.name = newValue
        }
    }
    var id: Int64{
        get{
            return self.contact!.id
        }
    }

    var contact : EvePlayerOwned?
    var contact_id : Int64?
    var contact_type : String?
    var standing : Float?
    var blocked : Bool? = false
    var watched : Bool? = false
    var type : ContactType?
    var label_id : Int?

    required init?(map: Map) {

    }

    init(contact : EvePlayerOwned, standing: Float, contactType : ContactType){
        self.contact = contact
        self.contact_id = contact.id
        self.contact_type = contactType.rawValue
        self.standing = standing
        self.type = contactType
    }

    func mapping(map: Map) {

        self.standing <- map["standing"]
        self.blocked <- map["is_blocked"]
        self.watched <- map["is_watched"]
        self.contact_id <- map["contact_id"]
        self.contact_type <- map["contact_type"]
        self.label_id <- map["label_id"]

        switch self.contact_type as! String{
            case "character":
                self.type = .character
                self.contact = EveCharacter(self.contact_id!)
            case "corporation":
                self.type = .corporation
                self.contact = EveCorporation(corporation_id: self.contact_id!)
            case "alliance":
                self.type = .alliance
                self.contact = EveAlliance(alliance_id: self.contact_id!)
            default:
                self.type = .unknown

        }

    }


}
