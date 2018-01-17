//
//  Type+CoreDataProperties.swift
//  EVE ESI
//
//  Created by Tristan Pollard on 2017-10-13.
//  Copyright © 2017 Sumo. All rights reserved.
//
//

import Foundation
import CoreData


extension Type {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Type> {
        return NSFetchRequest<Type>(entityName: "Type")
    }

    @NSManaged public var type_id: Int64
    @NSManaged public var group: Group?

}
