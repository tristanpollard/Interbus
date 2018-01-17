//
//  Group+CoreDataProperties.swift
//  EVE ESI
//
//  Created by Tristan Pollard on 2017-10-13.
//  Copyright © 2017 Sumo. All rights reserved.
//
//

import Foundation
import CoreData


extension Group {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
        return NSFetchRequest<Group>(entityName: "Group")
    }

    @NSManaged public var category_id: Int64
    @NSManaged public var group_id: Int64
    @NSManaged public var name: String?
    @NSManaged public var published: Bool
    @NSManaged public var types: NSSet?

}

// MARK: Generated accessors for types
extension Group {

    @objc(addTypesObject:)
    @NSManaged public func addToTypes(_ value: Type)

    @objc(removeTypesObject:)
    @NSManaged public func removeFromTypes(_ value: Type)

    @objc(addTypes:)
    @NSManaged public func addToTypes(_ values: NSSet)

    @objc(removeTypes:)
    @NSManaged public func removeFromTypes(_ values: NSSet)

}
