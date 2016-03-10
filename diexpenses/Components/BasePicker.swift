//
//  BasePicker.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 10/3/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit

// MARK: - Base view behaviour for pickers. It contains a UIToolbar that is showed when an UITextField is selected
class BasePicker {
    
    let uiTextField: UITextField
    
    init(uiTextField: UITextField, items: [UIBarButtonItem]) {
        
        self.uiTextField = uiTextField
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.BlackTranslucent
        toolBar.translucent = true
        toolBar.tintColor = UIColor.whiteColor()
        toolBar.sizeToFit()
        toolBar.setItems(items, animated: false)
        toolBar.userInteractionEnabled = true
        
        self.uiTextField.inputAccessoryView = toolBar
    }
    
    // MARK: Set text in associated UITextField and hides the picker
    func doCommonOperations(text: String) {
        uiTextField.text = text
        uiTextField.resignFirstResponder()
    }
}
