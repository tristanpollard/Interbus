//
//  StructureAttempts+CoreDataProperties.swift
//  
//
//  Created by Tristan Pollard on 2018-02-15.
//
//

import Foundation
import CoreData


extension StructureAttempts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StructureAttempts> {
        return NSFetchRequest<StructureAttempts>(entityName: "StructureAttempts")
    }

    @NSManaged public var character_id: Int64
    @NSManaged public var last_attempt: NSDate?
    @NSManaged public var valid: Bool
    @NSManaged public var structure: Structure?

}
