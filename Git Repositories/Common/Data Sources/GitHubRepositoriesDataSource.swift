//
//  GitHubRepositoriesDataSource.swift
//  Git Repositories
//
//  Created by Eugene Shcherbinock on 2/1/18.
//  Copyright © 2018 Organization. All rights reserved.
//

import Foundation
import CoreData

typealias RepositoriesResponse = (([RepositoryModel]) -> Void)

// MARK: - GitHubRepositoriesDataSource Protocol

protocol GitHubRepositoriesDataSource {
    
    var isFetching: Bool { get }
    
    func fetchRepositories(with query: String, limit: Int, _ completion: @escaping RepositoriesResponse)
    func cancelFetching()

}

// MARK: - GitHubRepositoriesDataSource Provider

class GitHubRepositoriesDataSourceProvider {
    
    class func getDataSource(_ isReachable: Bool) -> GitHubRepositoriesDataSource {
        guard isReachable else {
            return GitHubRepositoriesOfflineDataSource()
        }
        return GitHubRepositoriesOnlineDataSource()
    }
    
}

// MARK: - GitHubRepositoriesOnlineDataSource

class GitHubRepositoriesOnlineDataSource: GitHubRepositoriesDataSource {
    
    // MARK: - Properties
    
    var isFetching: Bool = false
    
    private let coreDataSaver: CoreDataSaver = CoreDataModelSaver()
    
    private var currentRequestGroup = DispatchGroup()
    private var currentOperationQueue = OperationQueue()
    
    // MARK: - Public Methods
    
    func fetchRepositories(with query: String, limit: Int, _ completion: @escaping RepositoriesResponse) {
        isFetching = true
        
        var firstPageRepositories = [RepositoryModel]()
        currentRequestGroup.enter()
        currentOperationQueue.addOperation { [unowned self] in
            self.fetch(query, limit, 1) { [weak self] (repositories) in
                firstPageRepositories = repositories
                self?.currentRequestGroup.leave()
            }
        }
        
        var secondPageRepositories = [RepositoryModel]()
        currentRequestGroup.enter()
        currentOperationQueue.addOperation { [unowned self] in
            self.fetch(query, limit, 2) { [weak self] (repositories) in
                secondPageRepositories = repositories
                self?.currentRequestGroup.leave()
            }
        }
        
        currentRequestGroup.notify(queue: .main, execute: { [weak self] in
            self?.isFetching = false
            completion(firstPageRepositories + secondPageRepositories)
        })
    }
    
    func cancelFetching() {
        
    }
    
    // MARK: - Private Methods
    
    private func fetch(_ query: String, _ limit: Int, _ page: Int, _ completion: @escaping RepositoriesResponse) {
        URLSession.shared.dataTask(with: GitHubAPIRouter.search(query: query, limit: limit, page: page).asURL()) { [weak self] (data, response, error) in
            guard let json = try! JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any] else {
                completion([RepositoryModel]())
                return
            }
            
            guard let repositoriesJson = json["items"] as? [[String : Any]] else {
                completion([RepositoryModel]())
                return
            }
            
            let repositories = repositoriesJson.map { RepositoryModel(json: $0)! }
            completion(repositories)
            
            repositories.forEach { self?.coreDataSaver.save(model: $0, forQuery: query, page: page) }
        }.resume()
    }
    
}

// MARK: - GitHubRepositoriesOfflineDataSource

class GitHubRepositoriesOfflineDataSource: GitHubRepositoriesDataSource {
    
    // MARK: - Properties
    
    var isFetching: Bool = false
    
    private let coreDataStack: CoreDataStack = CoreDataStackManager.shared
    
    private var currentRequestGroup = DispatchGroup()
    private var currentOperationQueue = OperationQueue()
    
    // MARK: - Public Methods
    
    func fetchRepositories(with query: String, limit: Int, _ completion: @escaping RepositoriesResponse) {
        isFetching = true
        
        var firstPageRepositories = [RepositoryModel]()
        currentRequestGroup.enter()
        currentOperationQueue.addOperation { [unowned self] in
            let fetchRequest: NSFetchRequest <RepositoryEntity> = RepositoryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "query == %@ AND page == %@", String(query), String(1))
            
            self.fetch(with: fetchRequest, limit: limit) { [unowned self] (repositories) in
                firstPageRepositories = repositories
                self.currentRequestGroup.leave()
            }
        }
        
        var secondPageRepositories = [RepositoryModel]()
        currentRequestGroup.enter()
        currentOperationQueue.addOperation { [unowned self] in
            let fetchRequest: NSFetchRequest <RepositoryEntity> = RepositoryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "query == %@ AND page == %@", String(query), String(2))
            
            self.fetch(with: fetchRequest, limit: limit) { [unowned self] (repositories) in
                secondPageRepositories = repositories
                self.currentRequestGroup.leave()
            }
        }
        
        currentRequestGroup.notify(queue: .main, execute: { [weak self] in
            self?.isFetching = false
            completion(firstPageRepositories + secondPageRepositories)
        })
    }
    
    func cancelFetching() {
        
    }
    
    // MARK: - Private Methods
    
    private func fetch(with fetchRequest: NSFetchRequest <RepositoryEntity>, limit: Int, _ completion: @escaping RepositoriesResponse) {
        fetchRequest.fetchLimit = limit
        
        var repositories = [RepositoryModel]()
        if let repositoriesEntities = try? self.coreDataStack.managedObjectContext.fetch(fetchRequest),
            repositoriesEntities.count > 0 {
            repositories = repositoriesEntities.map({ RepositoryModel(entity: $0) })
        }
        completion(repositories)
    }
    
}
