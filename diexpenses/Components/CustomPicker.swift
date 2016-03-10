//
//  CustomPicker.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 24/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit

// MARK: - UIPickerView with UIToolbar that is showed when an UITextField is selected
class CustomPicker: BasePicker {
    
    let picker: UIPickerView
    
    init(target: UIViewController, uiTextField: UITextField, items: [UIBarButtonItem]) {
        self.picker = UIPickerView(frame: CGRectMake(0, 0, target.view.frame.width, 250))
        super.init(uiTextField: uiTextField, items: items);
        
        self.picker.backgroundColor = Diexpenses.iosBorderColor
        self.picker.showsSelectionIndicator = true
        self.uiTextField.inputView = picker
    }
    
}
