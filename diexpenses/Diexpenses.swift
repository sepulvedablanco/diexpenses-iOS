//
//  Diexpenses.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 28/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import Foundation
import UIKit
import Gloss

class Diexpenses {
    
    static var user : User!
    
    static let DAY_MONTH_YEAR = "dd/MM/yyyy"
    static let DAY_MONTH_YEAR_WITH_HOUR = "dd/MM/yyyy hh:mm:ss"
    
    static let iosBorderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0)
    static let redColor = UIColor(red: 211/255, green: 73/255, blue: 78/255, alpha: 1.0)
    static let greenColor = UIColor(red: 116/255, green: 201/255, blue: 116/255, alpha: 1.0)
    static let blueColor = UIColor(red: 134/255, green: 216/255, blue: 247/255, alpha: 1.0)
    
    static func doRequest(url: String, headers: [NSObject : AnyObject], verb: String, body: String?, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        
        let requestURL = NSURL(string: url)!
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.HTTPAdditionalHeaders = headers
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = verb
        if let b = body {
            request.HTTPBody = b.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
        
        task.resume()
    }
    
    static func dealWithGenericResponse(controller: UIViewController, responseData: NSData?, expectedCode: Int?=nil) -> Bool {
        if let data = responseData {
            do {
                let genericApiResponseJson : AnyObject! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                let genericApiResponse = GenericApiResponse(json: genericApiResponseJson as! JSON)
                if let response = genericApiResponse {
                    if response.code == expectedCode {
                        return true
                    } else {
                        Diexpenses.showError(controller, message: response.message)
                    }
                } else {
                    Diexpenses.showUnknownError(controller)
                }
            } catch let error as NSError {
                NSLog("Error dealing with generic response: \(error.localizedDescription). Expected code: \(expectedCode)")
            }
        } else {
            NSLog("Without Internet connection")
        }
        return false
    }
    
    static func showUnknownError(controller: UIViewController) -> Void {
        let unknownError = UIAlertController(title: NSLocalizedString("common.error", comment: "The error title"), message: NSLocalizedString("common.unknownError", comment: "The unknown error message"), preferredStyle: .Alert)
        unknownError.addAction(UIAlertAction(title: NSLocalizedString("common.close", comment: "The close button"), style: .Default, handler: nil))
        controller.presentViewController(unknownError, animated: true, completion: nil)
    }

    static func showError(controller: UIViewController, message: String) -> Void {
        let error = UIAlertController(title: NSLocalizedString("common.error", comment: "The error title"), message: message, preferredStyle: .Alert)
        error.addAction(UIAlertAction(title: NSLocalizedString("common.close", comment: "The close button"), style: .Default, handler: nil))
        controller.presentViewController(error, animated: true, completion: nil)

    }

    static func formatDate(date: NSDate, format: String) -> String {
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = format
        return dayTimePeriodFormatter.stringFromDate(date)
    }
    
    static func formatDate(stringDate: String) -> NSDate {
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = DAY_MONTH_YEAR_WITH_HOUR
        return dayTimePeriodFormatter.dateFromString(stringDate)!
    }
    
    static func formatCurrency(value: NSNumber) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = NSLocale.currentLocale()
        formatter.maximumFractionDigits = 2
        return formatter.stringFromNumber(value)!
    }
    
    static func formatDecimalValue(string number: String) -> NSNumber {
        NSLog("\(number)")
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.locale = NSLocale.currentLocale()
        // Why current locale doesn't change the grouping and decimal separator? :(
        if formatter.locale.objectForKey(NSLocaleLanguageCode)! as! String == "en" {
            formatter.groupingSeparator = ","
            formatter.decimalSeparator = "."
        }
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter.numberFromString(number)!
    }
    
    static func formatDecimalValue(number number: NSNumber) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.locale = NSLocale.currentLocale()
        formatter.maximumFractionDigits = 2
        return formatter.stringFromNumber(number)!
    }
    
    static func getTypicalHeaders(sendToken: Bool = true) -> [NSObject : AnyObject] {
        var headers = ["Content-type": "application/json", "Accept-Language" : NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)!]
        if sendToken {
            headers.add(["X-AUTH-TOKEN" : user.authToken])
        }
        return headers
    }
}

enum HttpVerbs: String {
    case POST
    case GET
    case DELETE
    case PUT
}

enum KindsOperations: String {
    case NEW_KIND
    case EDIT_KIND
    case DELETE_KIND
    case NEW_SUBKIND
    case EDIT_SUBKIND
    case DELETE_SUBKIND
}

