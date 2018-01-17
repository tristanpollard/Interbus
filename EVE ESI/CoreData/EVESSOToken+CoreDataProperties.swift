//
//  EVESSOToken+CoreDataProperties.swift
//  
//
//  Created by Tristan Pollard on 2017-12-17.
//
//

import Foundation
import CoreData


extension EVESSOToken {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EVESSOToken> {
        return NSFetchRequest<EVESSOToken>(entityName: "EVESSOToken")
    }

    @NSManaged public var access_token: String?
    @NSManaged public var character_id: Int64
    @NSManaged public var character_name: String?
    @NSManaged public var expires: NSDate?
    @NSManaged public var refresh_token: String?
    @NSManaged public var token_type: String?
    @NSManaged public var scopes: String?

}
