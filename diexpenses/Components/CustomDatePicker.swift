//
//  CustomDatePicker.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 29/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit

class CustomDatePicker {

    let picker: UIDatePicker
    let uiTextField: UITextField
    
    init(target: UIViewController, uiTextField: UITextField, items: [UIBarButtonItem]) {
        self.picker = UIDatePicker(frame: CGRectMake(0, 0, target.view.frame.width, 250))
        self.uiTextField = uiTextField
        
        picker.backgroundColor = Diexpenses.iosBorderColor
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.BlackTranslucent
        toolBar.translucent = true
        toolBar.tintColor = UIColor.whiteColor() //UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        
        toolBar.setItems(items, animated: false)
        toolBar.userInteractionEnabled = true
        
        uiTextField.inputView = picker
        uiTextField.inputAccessoryView = toolBar
    }
    
    func doCommonOperations(text: String) {
        uiTextField.text = text
        uiTextField.resignFirstResponder()
    }
}
