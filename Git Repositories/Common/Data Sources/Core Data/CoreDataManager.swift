//
//  CoreDataManager.swift
//  Git Repositories
//
//  Created by Eugene Shcherbinock on 2/1/18.
//  Copyright © 2018 Organization. All rights reserved.
//

import Foundation
import CoreData

// MARK: - CoreDataStack Protocol

protocol CoreDataStack {
    
    var managedObjectModel: NSManagedObjectModel { get }
    var persistentStoreCoordinator: NSPersistentStoreCoordinator { get }
    var managedObjectContext: NSManagedObjectContext { get }
    
    func saveContextChanges()
    
}

// MARK: - CoreDataSaver Protocol

protocol CoreDataSaver {
    
    var coreDataStack: CoreDataStack { get }
    
    func save(model: RepositoryModel, forQuery: String, page: Int)
    
}

// MARK: - CoreDataStackManager

class CoreDataStackManager: CoreDataStack {
    
    private let storageName = "Git_Repositories"
    
    static let shared = CoreDataStackManager()
    
    // MARK: - Properties
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: storageName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("\(storageName).sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            fatalError("Persistent store error: \(error)")
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.savingManagedObjectContext
        return managedObjectContext
    }()
    
    private lazy var applicationDocumentsDirectory: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }()
    
    private lazy var savingManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Public Methods
    
    func saveContextChanges() {
        guard managedObjectContext.hasChanges || savingManagedObjectContext.hasChanges else {
            return
        }
        managedObjectContext.performAndWait() {
            do {
                try self.managedObjectContext.save()
            } catch {
                fatalError("Managed object context error: \(error)")
            }
        }
        savingManagedObjectContext.perform() {
            do {
                try self.savingManagedObjectContext.save()
            } catch {
                fatalError("Managed object context error: \(error)")
            }
        }
    }
    
}

// MARK: - CoreDataModelSaver

class CoreDataModelSaver: CoreDataSaver {
    
    // MARK: - Properties
    
    var coreDataStack: CoreDataStack = CoreDataStackManager.shared
    
    // MARK: - Public Methods
    
    func save(model: RepositoryModel, forQuery: String, page: Int) {
        let repositoryEntityInformation = prepareUniqueEntity(for: model)
        
        if repositoryEntityInformation.justCreated {
            repositoryEntityInformation.entity.query = forQuery
            repositoryEntityInformation.entity.page = Int16(page)
        }
        coreDataStack.saveContextChanges()
    }
    
    // MARK: = Private Methods
    
    private func prepareUniqueEntity(for model: RepositoryModel) -> (entity: RepositoryEntity, justCreated: Bool) {
        let fetchRequest: NSFetchRequest <RepositoryEntity> = RepositoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", String(model.id))
        
        var entity: RepositoryEntity!
        var created = false
        
        if let entities = try? fetchRequest.execute(), entities.count > 0 {
            entity = entities.first!
        } else {
            let entityDescription = NSEntityDescription.entity(forEntityName: "RepositoryEntity", in: coreDataStack.managedObjectContext)
            entity = RepositoryEntity(entity: entityDescription!, insertInto: coreDataStack.managedObjectContext)
            created = true
        }
        entity.fillWith(model: model)
        return (entity, created)
    }
    
}
