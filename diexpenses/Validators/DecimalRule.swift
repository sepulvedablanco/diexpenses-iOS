//
//  DecimalRule.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 31/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import SwiftValidator


// MARK: - Decimal validator for SwiftValidator. This validator is Region Dependant. It can validate numbers from all regions
class DecimalRule: Rule {
    
    var message: String = NSLocalizedString("common.validator.decimal", comment: "The validator message")

    init(){}

    init(message: String){
        self.message = message
    }
    
    // MARK: Validate implementation for Rule protocol
    func validate(value: String) -> Bool {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        let number : NSNumber? = formatter.numberFromString(value)
        return number != nil
    }

    // MARK: Error message implementation for Rule protocol
    func errorMessage() -> String {
        return message
    }
}