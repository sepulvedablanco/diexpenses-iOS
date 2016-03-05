//
//  DecimalRule.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 31/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import SwiftValidator

/*
 * This validator is Region Dependant. It can validate numbers from all regions
 */
class DecimalRule: Rule {
    
    var message: String = NSLocalizedString("common.validator.decimal", comment: "The validator message")

    init(){}

    init(message: String){
        self.message = message
    }
    
    func validate(value: String) -> Bool {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        let number : NSNumber? = formatter.numberFromString(value)
        return number != nil
    }
    
    func errorMessage() -> String {
        return message
    }
}