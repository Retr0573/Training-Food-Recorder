//
//  T_Item+CoreDataProperties.swift
//  HelloIOS
//
//  Created by 吴圣琪 on 2025/4/15.
//
//

import Foundation
import CoreData


extension T_Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<T_Item> {
        return NSFetchRequest<T_Item>(entityName: "T_Item")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var sets: NSSet?
    @NSManaged public var theme: T_Theme?

}

// MARK: Generated accessors for sets
extension T_Item {

    public var getSets: [T_Set] {
        return Array(sets as? Set<T_Set> ?? [])
    }
        
    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: T_Set)

    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: T_Set)

    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSSet)

    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSSet)

}

extension T_Item : Identifiable {

}
