//
//  Constants.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 27/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Session {
        
        static let IS_LOGGED_IN = "isLoggedIn"
        static let USER = "user"

    }
    
    struct Segue {
        
        static let FROM_EPVC_TO_LOGIN_VC = "fromEntryPointVCToLoginVC"
        static let FROM_EPVC_TO_HOME_VC = "fromEntryPointVCToHomeVC"
        static let TO_HOME_VC = "toHomeViewController"
        static let TO_LOGIN_VC = "toLoginViewController"
        static let TO_NEW_BANK_ACCOUNT_VC = "toNewBankAccountViewController";
        static let TO_EXPENSES_SUBKINDS_VC = "toExpensesSubkindsViewController";
    
    }
    
    struct Notifications {
        
        static let BANK_ACCOUNTS_CHANGED = "BANK_ACCOUNTS_CHANGED"
        static let INCOMES_CHANGED = "INCOMES_CHANGED"
        static let EXPENSES_CHANGED = "EXPENSES_CHANGED"
        
    }
    
    struct API {
        
        static let BASE_URL = "https://diexpenses.herokuapp.com/"
        static let LOGIN_URL = BASE_URL + "user/login"
        static let CREATE_USER_URL = BASE_URL + "user"
        static let AMOUNTS_URL = BASE_URL + "user/%@/financialMovements/amounts?e=%@&m=%@&y=%@"
        
        static let TOTAL_AMOUNT_URL = LIST_BANK_ACCOUNTS_URL + "/amount"
        static let LIST_BANK_ACCOUNTS_URL = BASE_URL + "user/%@/bankAccounts"
        static let CREATE_BANK_ACCOUNT_URL = BASE_URL + "user/%@/bankAccount"
        static let UD_BANK_ACCOUNT_URL = BASE_URL + "user/%@/bankAccount/%@" /* UD = Update and Delete */
        
        static let LIST_FIN_MOV_TYPES = BASE_URL + "user/%@/financialMovementTypes"
        static let CREATE_FIN_MOV_TYPES = BASE_URL + "user/%@/financialMovementType"
        static let UD_FIN_MOV_TYPES = BASE_URL + "user/%@/financialMovementType/%@" /* UD = Update and Delete */

        static let LIST_FIN_MOV_SUBTYPES = BASE_URL + "user/financialMovementType/%@/financialMovementSubtypes"
        static let CREATE_FIN_MOV_SUBTYPES = BASE_URL + "user/financialMovementType/%@/financialMovementSubtype"
        static let UD_FIN_MOV_SUBTYPES = BASE_URL + "user/financialMovementType/%@/financialMovementSubtype/%@" /* UD = Update and Delete */
        
        static let LIST_MOV_BY_MONTH = BASE_URL + "user/%@/financialMovements?y=%@&m=%@" /* e=true& */
        static let CREATE_MOVEMENT_URL = BASE_URL + "user/%@/financialMovement"
        static let UD_MOVEMENT_URL = BASE_URL + "user/%@/financialMovement/%@" /* UD = Update and Delete */
        
        static let STATISTICS_URL = BASE_URL + "user/%@/financialMovements/amounts?e=%@"
    }
    
    struct Cell {
        
        static let BASIC_IDENTIFIER = "BasicCell"

    }
    
    struct Images {
        static let MINUS = "minus.png"
        static let PLUS = "plus.png"
        static let UNKNOW_ENTITY = "Unknown.png"
    }
    
}