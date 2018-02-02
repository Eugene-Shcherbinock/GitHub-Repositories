//
//  Repository.swift
//  Git Repositories
//
//  Created by Eugene Shcherbinock on 2/1/18.
//  Copyright © 2018 Organization. All rights reserved.
//

import Foundation

class RepositoryModel {
    
    var id: Int
    var name: String
    var fullName: String
    var url: String
    var scores: Double
    var description: String?
    
    init?(json: [String : Any]) {
        guard let id = json["id"] as? Int, let name = json["name"] as? String,
            let fullName = json["full_name"] as? String, let url = json["html_url"] as? String,
            let scores = json["score"] as? Double else {
                return nil
        }
        
        self.id = id
        self.name = name
        self.fullName = fullName
        self.url = url
        self.scores = scores
        self.description = json["description"] as? String
    }
    
    init(entity: RepositoryEntity) {
        id = Int(entity.id)
        name = entity.name
        fullName = entity.fullName
        description = entity.desc
        url = entity.url
        scores = entity.scores
    }
    
}
