//
//  RepositoriesSearchPresenter.swift
//  Git Repositories
//
//  Created by Eugene Shcherbinock on 2/1/18.
//  Copyright © 2018 Organization. All rights reserved.
//

import UIKit

// MARK: - RepositoriesSearchViewPresenter Protocol

protocol RepositoriesSearchViewPresenter: class {
    
    weak var view: RepositoriesSearchView! { get }
    
    func didLoad(view: RepositoriesSearchView)
    
    func reloadData()
    func searchRepositoriesWithQuery(from searchBar: UISearchBar)
    
    func numberOfSections() -> Int
    func numberOfRows(in section: Int) -> Int
    func didSelectRow(at indexPath: IndexPath)
    func getRepositoryForRow(at indexPath: IndexPath) -> RepositoryModel
    
}

// MARK: - RepositoriesSearchPresenter

class RepositoriesSearchPresenter: RepositoriesSearchViewPresenter {
    
    // MARK: - Properties
    
    weak var view: RepositoriesSearchView!
    
    private let onlineDataSource = GitHubRepositoriesDataSourceProvider.getDataSource(true)
    private let offlineDataSource = GitHubRepositoriesDataSourceProvider.getDataSource(false)
    
    private var currentSearchQuery = ""
    private var currentRepositories = [RepositoryModel]()
    
    // MARK: - Methods
    
    func didLoad(view: RepositoriesSearchView) {
        self.view = view
    }
    
    func reloadData() {
        guard Reachability.isReachable() else {
            view.showLoadingIndicator(false)
            return
        }
        
        view.showLoadingIndicator(true)
        fetchRepositories(from: onlineDataSource, currentSearchQuery)
    }
    
    func searchRepositoriesWithQuery(from searchBar: UISearchBar) {
        guard let searchQuery = searchBar.text else {
            return
        }
        searchBar.resignFirstResponder()
        currentSearchQuery = searchQuery.replacingOccurrences(of: " ", with: "-")
        
        view.showLoadingIndicator(true)
        fetchRepositories(from: Reachability.isReachable() ? onlineDataSource : offlineDataSource, currentSearchQuery)
    }
    
    func numberOfSections() -> Int {
        return currentRepositories.isEmpty ? 0 : 1
    }
    
    func numberOfRows(in section: Int) -> Int {
        return currentRepositories.count
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard Reachability.isReachable() else {
            return
        }
        
        let selectedRepositoryURL = URL(string: currentRepositories[indexPath.row].url)!
        view.showRepository(selectedRepositoryURL)
    }
    
    func getRepositoryForRow(at indexPath: IndexPath) -> RepositoryModel {
        return currentRepositories[indexPath.row]
    }
    
}

// MARK: - Private Methods

extension RepositoriesSearchPresenter {
    
    private func fetchRepositories(from dataSource: GitHubRepositoriesDataSource, _ query: String) {
        if dataSource.isFetching {
            dataSource.cancelFetching()
        }
        dataSource.fetchRepositories(with: query, limit: 15) { [weak self] (repositories) in
            self?.currentRepositories = repositories
            self?.view.showLoadingIndicator(false)
            self?.view.reloadRepositoriesView(!repositories.isEmpty)
        }
    }
    
}
