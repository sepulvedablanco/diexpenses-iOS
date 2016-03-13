//
//  Constants.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 27/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit

// MARK: - Loading mask for heavy operations.
class LoadingMask {

    var messageFrame: UIView!
    var parentView: UIView!
    
    init(view: UIView) {
        self.parentView = view
        self.messageFrame = UIView(frame: CGRect(x: parentView.frame.midX - 40, y: parentView.frame.midY - 40 , width: 80, height: 80))
        self.messageFrame.layer.cornerRadius = 15
        self.messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        activityIndicator.startAnimating()
        self.messageFrame.addSubview(activityIndicator)
    }
    
    func showMask() {
        dispatch_async(dispatch_get_main_queue(), {
            self.parentView.addSubview(self.messageFrame)
        })
    }
    
    func hideMask() {
        dispatch_async(dispatch_get_main_queue(), {
            self.messageFrame.removeFromSuperview()
        })
    }
    
}