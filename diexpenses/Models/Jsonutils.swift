//
//  File.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 1/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import Foundation

class JsonUtils {
    
    static func JSONStringify(value: AnyObject, prettyPrinted:Bool = false) -> String {
        
        let options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : NSJSONWritingOptions(rawValue: 0)
        
        if NSJSONSerialization.isValidJSONObject(value) {
            
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(value, options: options)
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }
            } catch let error as NSError {
                print("Error while converting JSON: \(error.description)")
            }
            
        }
        return ""
    }
}
