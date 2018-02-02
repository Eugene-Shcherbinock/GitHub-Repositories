//
//  RepositoriesSearchViewController.swift
//  Git Repositories
//
//  Created by Eugene Shcherbinock on 2/1/18.
//  Copyright © 2018 Organization. All rights reserved.
//

import UIKit

// MARK: - RepositoriesSearchView Protocol

protocol RepositoriesSearchView: class {
    
    var presenter: RepositoriesSearchViewPresenter! { get }
    
    func showLoadingIndicator(_ state: Bool)
    func reloadRepositoriesView(_ hasContent: Bool)
    
    func showRepository(_ url: URL)
    
}

// MARK: - RepositoriesSearchViewController

class RepositoriesSearchViewController: UIViewController {
    
    // MARK: Properties
    
    var presenter: RepositoriesSearchViewPresenter! = RepositoriesSearchPresenter()
    
    private lazy var noItemsLabel: UILabel = {
        var label = UILabel(frame: repositoriesTableView.bounds)
        label.text = "No items found..."
        label.textAlignment = .center
        label.isHidden = false
        return label
    }()
    
    private lazy var refreshControll: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        refresh.sizeToFit()
        return refresh
    }()

    // MARK: - IBOutlets
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var repositoriesTableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewDependencies()
        
        presenter.didLoad(view: self)
    }
    
    // MARK: - UIRefreshControl Target
    
    @objc private func pullToRefresh() {
        presenter.reloadData()
    }
    
}

// MARK: - RepositoriesSearchView Implementation

extension RepositoriesSearchViewController: RepositoriesSearchView {
    
    func showLoadingIndicator(_ state: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = state
        if !state && refreshControll.isRefreshing {
            refreshControll.endRefreshing()
        }
    }
    
    func reloadRepositoriesView(_ hasContent: Bool) {
        noItemsLabel.isHidden = hasContent
        repositoriesTableView.reloadData()
        
        if hasContent {
            repositoriesTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func showRepository(_ url: URL) {
        let webView = ModalWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width - 10, height: view.frame.height / 2))
        webView.loadRequest(URLRequest(url: url))
        view.addSubview(webView)
    }
    
}

// MARK: - UITableViewDelegate

extension RepositoriesSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
    }
    
}

// MARK: - UITableViewDataSource

extension RepositoriesSearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.reuseIdentifier, for: indexPath) as! RepositoryTableViewCell
        cell.bind(with: presenter.getRepositoryForRow(at: indexPath))
        return cell
    }
    
}

// MARK: - UISearchBarDelegate

extension RepositoriesSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchRepositoriesWithQuery(from: searchBar)
    }
    
}

// MARK: - Private Methods

extension RepositoriesSearchViewController {
    
    private func updateViewDependencies() {
        searchBar.delegate = self
        
        repositoriesTableView.delegate = self
        repositoriesTableView.dataSource = self
        repositoriesTableView.register(UINib(nibName: "RepositoryTableViewCell", bundle: nil), forCellReuseIdentifier: RepositoryTableViewCell.reuseIdentifier)
        
        repositoriesTableView.refreshControl = refreshControll
        repositoriesTableView.addSubview(noItemsLabel)
    }
    
}
