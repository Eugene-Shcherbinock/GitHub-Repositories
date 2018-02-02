//
//  Extensions.swift
//  Git Repositories
//
//  Created by Eugene Shcherbinock on 2/2/18.
//  Copyright © 2018 Organization. All rights reserved.
//

import UIKit

// MARK: - UILabel

extension UILabel {
    
    func setText(_ text: String, maxLength: Int = 30) {
        guard text.count > maxLength else {
            self.text = text
            return
        }
        
        let maxLengthIndex = text.index(text.startIndex, offsetBy: maxLength)
        self.text = "\(text[..<maxLengthIndex])..."
    }
    
}
