//
// Created by Tristan Pollard on 2018-12-16.
// Copyright (c) 2018 Tristan Pollard. All rights reserved.
//

import Foundation
import ObjectMapper

class EveWalletJournalItem: Mappable {

    var amount: Double?
    var balance: Double?
    var context_id: Int64?
    var context_id_type: String?
    var date: Date!
    var description: String!
    var first_party_id: Int64?
    var id: Int64!
    var reason: String?
    var ref_type: String?
    var second_party_id: Int64?
    var tax: Double?
    var tax_receiver_id: Int64?

    var first_party: EveWalletJournalItemParty?
    var second_party: EveWalletJournalItemParty?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.amount <- map["amount"]
        self.balance <- map["balance"]
        self.context_id <- map["context_id"]
        self.context_id_type <- map["context_id_type"]
        self.date <- (map["date"], DateTransform())
        self.description <- map["description"]
        self.first_party_id <- map["first_party_id"]
        self.id <- map["id"]
        self.reason <- map["reason"]
        self.ref_type <- map["ref_type"]
        self.second_party_id <- map["second_party_id"]
        self.tax <- map["tax"]
        self.tax_receiver_id <- map["tax_receiver_id"]

        if let firstParty = self.first_party_id {
            self.first_party = EveWalletJournalItemParty(id: firstParty)
        }
        if let secondParty = self.second_party_id {
            self.second_party = EveWalletJournalItemParty(id: secondParty)
        }
    }
}

extension Array where Element == EveWalletJournalItem {
    func fetchPartyNames(completion: @escaping () -> ()) {
        var parties: [EveWalletJournalItemParty] = []
        self.forEach { item in
            if let firstParty = item.first_party {
                parties.append(firstParty)
            }
            if let secondParty = item.second_party {
                parties.append(secondParty)
            }
        }
        parties.fetchNames {
            completion()
        }
    }
}
