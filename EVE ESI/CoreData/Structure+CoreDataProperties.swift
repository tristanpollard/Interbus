//
//  Structure+CoreDataProperties.swift
//  
//
//  Created by Tristan Pollard on 2018-02-15.
//
//

import Foundation
import CoreData


extension Structure {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Structure> {
        return NSFetchRequest<Structure>(entityName: "Structure")
    }

    @NSManaged public var name: String?
    @NSManaged public var structure_id: Int64
    @NSManaged public var valid: Bool
    @NSManaged public var attempts: NSSet?

}

// MARK: Generated accessors for attempts
extension Structure {

    @objc(addAttemptsObject:)
    @NSManaged public func addToAttempts(_ value: StructureAttempts)

    @objc(removeAttemptsObject:)
    @NSManaged public func removeFromAttempts(_ value: StructureAttempts)

    @objc(addAttempts:)
    @NSManaged public func addToAttempts(_ values: NSSet)

    @objc(removeAttempts:)
    @NSManaged public func removeFromAttempts(_ values: NSSet)

}
