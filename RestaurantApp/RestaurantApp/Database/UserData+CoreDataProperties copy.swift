//
//  UserData+CoreDataProperties.swift
//  
//
//  Created by AbhishekSir on 11/14/18.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var tokenId: String?

}
