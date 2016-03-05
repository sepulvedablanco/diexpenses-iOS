//
//  Constants.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 27/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit

class LoadingMask {

    var messageFrame : UIView!
    
    func showMask(view: UIView) {
        dispatch_async(dispatch_get_main_queue(), {
            self.messageFrame = UIView(frame: CGRect(x: view.frame.midX - 40, y: view.frame.midY - 40 , width: 80, height: 80))
            self.messageFrame.layer.cornerRadius = 15
            self.messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            activityIndicator.startAnimating()
            self.messageFrame.addSubview(activityIndicator)
            view.addSubview(self.messageFrame)
        })
    }
    
    func hideMask() {
        if messageFrame != nil {
            dispatch_async(dispatch_get_main_queue(), {
                self.messageFrame.removeFromSuperview()
            })
        }
    }
    
}