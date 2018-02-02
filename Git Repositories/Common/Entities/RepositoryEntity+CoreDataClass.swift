//
//  RepositoryEntity+CoreDataClass.swift
//  Git Repositories
//
//  Created by Eugene Shcherbinock on 2/2/18.
//  Copyright © 2018 Organization. All rights reserved.
//
//

import Foundation
import CoreData

@objc(RepositoryEntity)
public class RepositoryEntity: NSManagedObject {

    func fillWith(model: RepositoryModel) {
        id = Int32(model.id)
        name = model.name
        fullName = model.fullName
        desc = model.description
        url = model.url
        scores = model.scores
    }
    
}
