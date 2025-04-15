//
//  T_Set+CoreDataProperties.swift
//  HelloIOS
//
//  Created by 吴圣琪 on 2025/4/15.
//
//

import Foundation
import CoreData


extension T_Set {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<T_Set> {
        return NSFetchRequest<T_Set>(entityName: "T_Set")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isWarmup: Bool
    @NSManaged public var reps: Int16
    @NSManaged public var restTime: Int16
    @NSManaged public var weight: Double
    @NSManaged public var order: Int16
    @NSManaged public var item: T_Item?

}

extension T_Set : Identifiable {

}
