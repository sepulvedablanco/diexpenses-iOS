//
//  CustomScrollView.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 5/3/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit

class CustomScrollView: UIScrollView {
    
    var activeField: UITextField?
    var view: UIView?
    
    func configure(view: UIView) {
        self.view = view
        let scrollSize = CGSizeMake(view.frame.width, self.contentSize.height)
        self.contentSize = scrollSize
        registerForKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications() {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
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
    
    func keyboardWillBeHidden(notification: NSNotification) {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.contentInset = contentInsets
        self.scrollIndicatorInsets = contentInsets
        self.view!.endEditing(true)
        self.scrollEnabled = false
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
}