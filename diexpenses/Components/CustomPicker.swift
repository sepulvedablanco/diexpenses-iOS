//
//  CustomPicker.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 24/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit

// MARK: - UIPickerView with UIToolbar that is showed when an UITextField is selected
class CustomPicker {
    
    let picker: UIPickerView
    let uiTextField: UITextField
    
    init(target: UIViewController, uiTextField: UITextField, items: [UIBarButtonItem]) {
        self.picker = UIPickerView(frame: CGRectMake(0, 0, target.view.frame.width, 250))
        self.uiTextField = uiTextField
        
        picker.backgroundColor = Diexpenses.iosBorderColor
        
        picker.showsSelectionIndicator = true
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.BlackTranslucent
        toolBar.translucent = true
        toolBar.tintColor = UIColor.whiteColor()
        toolBar.sizeToFit()
                
        
        toolBar.setItems(items, animated: false)
        toolBar.userInteractionEnabled = true
        
        uiTextField.inputView = picker
        uiTextField.inputAccessoryView = toolBar
    }
    
    // MARK: Set text in associated UITextField and hides the picker
    func doCommonOperations(text: String) {
        uiTextField.text = text
        uiTextField.resignFirstResponder()
    }
}
