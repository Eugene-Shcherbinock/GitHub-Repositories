//
//  GitHubAPI.swift
//  Git Repositories
//
//  Created by Eugene Shcherbinock on 2/1/18.
//  Copyright © 2018 Organization. All rights reserved.
//

import Foundation

enum GitHubAPIRouter: URLConvertible {
    
    static let baseUrl = "https://api.github.com"
    
    case search(query: String, limit: Int, page: Int)
    
    var path: String {
        switch self {
        case .search(let query, let limit, let page):
            return "\(GitHubAPIRouter.baseUrl)/search/repositories?sort=stars&q=\(query)&per_page=\(limit)&page=\(page)"
        }
    }
    
    func asURL() -> URL {
        return URL(string: path)!
    }
    
}
