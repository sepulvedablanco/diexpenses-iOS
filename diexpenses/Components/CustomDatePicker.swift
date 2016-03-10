//
//  CustomDatePicker.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 29/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit

// MARK: - UIDatePicker with UIToolbar that is showed when an UITextField is selected
class CustomDatePicker: BasePicker {

    let picker: UIDatePicker
    
    init(target: UIViewController, uiTextField: UITextField, items: [UIBarButtonItem]) {
        self.picker = UIDatePicker(frame: CGRectMake(0, 0, target.view.frame.width, 250))
        super.init(uiTextField: uiTextField, items: items)
        
        self.picker.backgroundColor = Diexpenses.iosBorderColor
        self.uiTextField.inputView = picker
    }
}
