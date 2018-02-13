import Foundation
import ObjectMapper

class EveTransaction : Mappable, Nameable{

    var id : Int64 {
        get {
            return self.type_id!
        }
    }
    var name: String = ""

    var transaction_id : Int64?
    var journal_ref_id : Int64?
    var type_id : Int64?
    var is_personal : Bool?
    var unit_price : Int?
    var client_id : Int64?
    var date : Date?
    var is_buy : Bool?
    var quantity : Int?
    var location_id : Int64?

    var client: EveCharacter?

    required init?(map: Map) {

    }

    func mapping(map: Map) {

        self.transaction_id <- map["transaction_id"]
        self.journal_ref_id <- map["journal_ref_id"]
        self.type_id <- map["type_id"]
        self.is_personal <- map["is_personal"]
        self.unit_price <- map["unit_price"]
        self.client_id <- map["client_id"]
        self.is_buy <- map["is_buy"]
        self.quantity <- map["quantity"]
        self.location_id <- map["location_id"]
        self.client = EveCharacter(self.client_id!)

    }
}
