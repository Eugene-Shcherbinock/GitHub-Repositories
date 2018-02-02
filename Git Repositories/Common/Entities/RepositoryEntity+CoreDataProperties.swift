//
//  RepositoryEntity+CoreDataProperties.swift
//  Git Repositories
//
//  Created by Eugene Shcherbinock on 2/2/18.
//  Copyright © 2018 Organization. All rights reserved.
//
//

import Foundation
import CoreData

extension RepositoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RepositoryEntity> {
        return NSFetchRequest<RepositoryEntity>(entityName: "RepositoryEntity")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String
    @NSManaged public var fullName: String
    @NSManaged public var url: String
    @NSManaged public var scores: Double
    @NSManaged public var desc: String?
    @NSManaged public var query: String
    @NSManaged public var page: Int16

}
