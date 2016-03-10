//
//  CustomScrollView.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 5/3/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit

// MARK: - Custom scroll view to enable scrolling views
class CustomScrollView: UIScrollView {
    
    var activeField: UITextField?
    var view: UIView?
    
    func configure(view: UIView) {
        self.view = view
        let scrollSize = CGSizeMake(view.frame.width, self.contentSize.height)
        self.contentSize = scrollSize
        registerForKeyboardNotifications()
    }

}

// MARK: - UITextFieldDelegate implementation for CustomScrollView
extension CustomScrollView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
}

// MARK: - Implementation for keyboard notifications
extension CustomScrollView {
    
    // MARK: Adding notifies on keyboard appearing
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }

    // MARK: Removing notifies on keyboard appearing
    func deregisterFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}

// MARK: - Implementation for keyboard show/hide actions
extension CustomScrollView {
    
    // MARK: Need to calculate keyboard exact size due to Apple suggestions
    func keyboardWasShown(notification: NSNotification) {
        self.scrollEnabled = true
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.contentInset = contentInsets
        self.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = view!.frame
        aRect.size.height -= keyboardSize!.height
        if let _ = activeField {
            if (!CGRectContainsPoint(aRect, activeField!.frame.origin)) {
                self.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
    }
    
    // MARK: Once keyboard disappears, restore original positions
    func keyboardWillBeHidden(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.contentInset = contentInsets
        self.scrollIndicatorInsets = contentInsets
        self.view!.endEditing(true)
        self.scrollEnabled = false
    }
}