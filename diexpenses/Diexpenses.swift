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

// MARK: - Main usefulness of the application
class Diexpenses {
    
    static var user : User!
    
    static let DAY_MONTH_YEAR = "dd/MM/yyyy"
    static let DAY_MONTH_YEAR_WITH_HOUR = "dd/MM/yyyy hh:mm:ss"
    
    static let iosBorderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0)
    static let redColor = UIColor(red: 211/255, green: 73/255, blue: 78/255, alpha: 1.0)
    static let greenColor = UIColor(red: 116/255, green: 201/255, blue: 116/255, alpha: 1.0)
    static let blueColor = UIColor(red: 134/255, green: 216/255, blue: 247/255, alpha: 1.0)
    
}

// MARK: - HTTP Utils
extension Diexpenses {
    
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
    
    static func getTypicalHeaders(sendToken: Bool = true) -> [NSObject : AnyObject] {
        var headers = ["Content-type": "application/json", "Accept-Language" : NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)!]
        if sendToken {
            headers.add(["X-AUTH-TOKEN" : user.authToken])
        }
        return headers
    }
}

// MARK: - Formatters Utils
extension Diexpenses {
    
    static func formatDate(date: NSDate, format: String) -> String {
        NSLog("formatDate -> Date to format:\(date). Format:\(format)")
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = format
        return dayTimePeriodFormatter.stringFromDate(date)
    }
    
    static func formatDate(stringDate: String) -> NSDate {
        NSLog("formatDate -> String to format:\(stringDate)")
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = DAY_MONTH_YEAR_WITH_HOUR
        return dayTimePeriodFormatter.dateFromString(stringDate)!
    }
    
    static func formatCurrency(value: NSNumber) -> String {
        NSLog("formatCurrency -> Number to format:\(value)")
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = NSLocale.currentLocale()
        formatter.maximumFractionDigits = 2
        return formatter.stringFromNumber(value)!
    }
    
    static func formatDecimalValue(string number: String) -> NSNumber {
        NSLog("formatDecimalValue -> String to format:\(number)")
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.locale = NSLocale.currentLocale()
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter.numberFromString(number)!
    }
    
    static func formatDecimalValue(number number: NSNumber) -> String {
        NSLog("formatDecimalValue -> Number to format:\(number)")
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.locale = NSLocale.currentLocale()
        formatter.maximumFractionDigits = 2
        return formatter.stringFromNumber(number)!
    }
}

// MARK: - UI Utils
extension Diexpenses {
    
    static func showUnknownError(controller: UIViewController) -> Void {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let unknownError = UIAlertController(title: NSLocalizedString("common.error", comment: "The error title"), message: NSLocalizedString("common.unknownError", comment: "The unknown error message"), preferredStyle: .Alert)
            unknownError.addAction(UIAlertAction(title: NSLocalizedString("common.close", comment: "The close button"), style: .Default, handler: nil))
            controller.presentViewController(unknownError, animated: true, completion: nil)
        })
    }
    
    static func showError(controller: UIViewController, message: String) -> Void {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let error = UIAlertController(title: NSLocalizedString("common.error", comment: "The error title"), message: message, preferredStyle: .Alert)
            error.addAction(UIAlertAction(title: NSLocalizedString("common.close", comment: "The close button"), style: .Default, handler: nil))
            controller.presentViewController(error, animated: true, completion: nil)
        })
    }
    
    static func switchButton(button: UIButton) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            button.enabled = !button.enabled
            button.alpha = button.enabled ? 1.0 : 0.5
        })
    }
    
    static func createRefreshControl(controller: UIViewController, actionName name: Selector) -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(controller, action: name, forControlEvents: .ValueChanged)
        return refreshControl
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

