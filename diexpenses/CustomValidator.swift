//
//  CustomValidatorDelegate.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 7/3/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import SwiftValidator

//Validator
// MARK: - Generic APP form validator. It is an extension for SwiftValidator with the common source code.
class CustomValidator: Validator {
    
    override init() {
        super.init()
        setValidationStyles()
    }
    
    // MARK: Method called when validation failed
    func validationFailed(errors:[UITextField:ValidationError]) {
        for (field, error) in errors {
            setErrorStyle(field, errorLabel: error.errorLabel!, errorMessage: error.errorMessage)
        }
    }
    
    // MARK: Set the validation styles for the UITextFields inside the form
    func setValidationStyles() {
        styleTransformers(
            success:{ (validationRule) -> Void in
                self.setValidStyle(validationRule.textField, errorLabel: validationRule.errorLabel!)
            },
            error:{ (validationError) -> Void in
                self.setErrorStyle(validationError.textField, errorLabel: validationError.errorLabel!, errorMessage: validationError.errorMessage)
        })
    }
    
    // MARK: Set the validation styles for valid fields
    func setValidStyle(input: UIView, errorLabel: UILabel) {
        input.layer.borderColor = Diexpenses.greenColor.CGColor
        input.layer.borderWidth = 0.5
        // clear error label
        errorLabel.hidden = true
        errorLabel.text = ""
    }
    
    // MARK: Set the validation styles for invalid fields
    func setErrorStyle(input: UIView, errorLabel: UILabel, errorMessage: String) {
        input.layer.borderColor = Diexpenses.redColor.CGColor
        input.layer.borderWidth = 1.0
        errorLabel.text = errorMessage
        errorLabel.hidden = false
    }
}