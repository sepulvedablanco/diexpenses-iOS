//
//  DigitValidator.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 31/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import SwiftValidator

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

    public func validate(value: String) -> Bool {
        let regex = String.localizedStringWithFormat("^\\d{%d}$", length)
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluateWithObject(value)
    }
    
    public func errorMessage() -> String {
        return String.localizedStringWithFormat(message, length)
    }
}