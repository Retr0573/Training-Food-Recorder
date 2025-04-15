//
//  T_Theme+CoreDataProperties.swift
//  HelloIOS
//
//  Created by 吴圣琪 on 2025/4/15.
//
//

import Foundation
import CoreData


extension T_Theme {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<T_Theme> {
        return NSFetchRequest<T_Theme>(entityName: "T_Theme")
    }

    @NSManaged public var coverImage: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension T_Theme {
    public var sortedItems: [T_Item] {
        let itemsArray = (items as? Set<T_Item>) ?? [] // 将 NSSet 转换为 Set<T_Item>
        return itemsArray.sorted { ($0.name ?? "") < ($1.name ?? "") } // 按 name 排序
    }
    
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: T_Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: T_Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension T_Theme : Identifiable {

}
