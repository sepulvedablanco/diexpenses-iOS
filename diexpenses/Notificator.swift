//
//  Notificator.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 6/3/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import Foundation

// MARK: - Set of utilities for notifications between view-controllers
class Notificator {
    
    // MARK: Utility that is launched after the creation or deletion of a movement (expense or income)
    static func fireNotification(expense expense: Bool!) {
        if let isExpense = expense {
            let notification = isExpense ? Constants.Notifications.EXPENSES_CHANGED : Constants.Notifications.INCOMES_CHANGED
            NSNotificationCenter.defaultCenter().postNotificationName(notification, object: nil)
        } else {
            NSLog("Warn - Movement without expense/income flag")
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.EXPENSES_CHANGED, object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.INCOMES_CHANGED, object: nil)
        }
    }
    
    // MARK: Utility that sends a parameterized notification
    static func fireNotification(notificationName notificationName: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil)
    }

}