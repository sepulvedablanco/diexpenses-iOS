//
//  DigitValidator.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 31/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import SwiftValidator

// MARK: - Digit validator for SwiftValidator. Validate that a String has n digits (4 by default)
public class DigitRule: Rule {
    
    private var length: Int = 4
    private var message = NSLocalizedString("common.validator.digit", comment: "The validator message")
    
    init() {}

    init(length: Int){
        self.length = length
    }
    
    convenience init(length: Int, message: String){
        self.init(length: length)
        self.message = message
    }

    // MARK: Validate implementation for Rule protocol
    public func validate(value: String) -> Bool {
        let regex = String.localizedStringWithFormat("^\\d{%d}$", length)
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluateWithObject(value)
    }
    
    // MARK: Error message implementation for Rule protocol
    public func errorMessage() -> String {
        return String.localizedStringWithFormat(message, length)
    }
}