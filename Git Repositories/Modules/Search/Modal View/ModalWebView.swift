//
//  ModalWebView.swift
//  Git Repositories
//
//  Created by Eugene Shcherbinock on 2/1/18.
//  Copyright © 2018 Organization. All rights reserved.
//

import UIKit

class ModalWebView: UIWebView {

    // MARK: - Public Properties
    
    private var shadowView: UIView!
    
    // MARK: - Initialization Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeShadowView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Lifecycle
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard let newSuperview = newSuperview else {
            return
        }
        center = newSuperview.center
        newSuperview.addSubview(shadowView)
    }
    
    override func removeFromSuperview() {
        shadowView.removeFromSuperview()
        super.removeFromSuperview()
    }
    
}

// MARK: - Private Methods

extension ModalWebView {
    
    private func initializeShadowView() {
        shadowView = UIView(frame: UIScreen.main.bounds)
        shadowView.alpha = 0.2
        shadowView.backgroundColor = .black
        shadowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
    }
    
    @objc private func dismissView() {
        removeFromSuperview()
    }
    
}

