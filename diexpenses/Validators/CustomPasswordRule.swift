//
//  CustomPasswordRule.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 14/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import SwiftValidator

// MARK: - Password validator for SwiftValidator
public class CustomPasswordRule : RegexRule {

    // MARK: expenses API password regex
    static let myPasswordRegex = "^((?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{6,20})$"
    
    public convenience init(message : String = NSLocalizedString("common.validator.password", comment: "The validator message")) {
        self.init(regex: CustomPasswordRule.myPasswordRegex, message: message)
    }    
}