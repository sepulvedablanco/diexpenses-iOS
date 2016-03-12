//
//  NewBankAccountViewController.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 31/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import Foundation
import UIKit
import Gloss
import SwiftValidator

class NewBankAccountViewController: UIViewController {
    
    let customValidator = CustomValidator()
    var bankAccount: BankAccount!

    @IBOutlet weak var scrollView: CustomScrollView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var descriptionErrorLabel: UILabel!
    @IBOutlet weak var ibanTextFied: UITextField!
    @IBOutlet weak var entityTextFied: UITextField!
    @IBOutlet weak var entityErrorLabel: UILabel!
    @IBOutlet weak var officeTextFied: UITextField!
    @IBOutlet weak var officeErrorLabel: UILabel!
    @IBOutlet weak var controlDigitTextFied: UITextField!
    @IBOutlet weak var controlDigitErrorLabel: UILabel!
    @IBOutlet weak var accountNumberTextFied: UITextField!
    @IBOutlet weak var accountNumberErrorLabel: UILabel!
    @IBOutlet weak var balanceTextFied: UITextField!
    @IBOutlet weak var balanceErrorLabel: UILabel!
    
    @IBAction func onCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var saveAndUpdateButton: UIBarButtonItem!
    @IBAction func onUpdateOrSave() {
        customValidator.validate(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        initVC()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        afterInitVC()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Extension for legacy operations
extension NewBankAccountViewController {
    
    // MARK: Initialize the View Controller
    func initVC() {
        scrollView.configure(view)
        setTextFieldsDelegate()
        registerFieldsInValidator()
    }
    
    // MARK: Updates the window title based on editing mode
    func afterInitVC() {
        if let _ = bankAccount {
            saveAndUpdateButton.title = NSLocalizedString("common.update", comment: "The update value")
            fillForm()
        }
    }
    
    // MARK: Fill the form with the bank account data when is editing mode
    func fillForm() {
        descriptionTextField.text = bankAccount.description
        ibanTextFied.text = bankAccount.iban
        entityTextFied.text = bankAccount.entity
        officeTextFied.text = bankAccount.office
        controlDigitTextFied.text = bankAccount.controlDigit
        accountNumberTextFied.text = bankAccount.accountNumber
        balanceTextFied.text = Diexpenses.formatDecimalValue(number: bankAccount.balance)
    }
}

// MARK: - UITextFieldDelegate implementation for NewBankAccountViewController
extension NewBankAccountViewController: UITextFieldDelegate {
    
    // MARK: Set the UITextFields form delegate
    func setTextFieldsDelegate() {
        descriptionTextField.delegate = self
        ibanTextFied.delegate = self
        entityTextFied.delegate = self
        officeTextFied.delegate = self
        controlDigitTextFied.delegate = self
        accountNumberTextFied.delegate = self
        balanceTextFied.delegate = self
    }
    
    // MARK: Method called when the user push Next in the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dispatch_async(dispatch_get_main_queue(), {
            if textField == self.descriptionTextField {
                textField.resignFirstResponder()
                self.ibanTextFied.becomeFirstResponder()
            } else if textField == self.ibanTextFied {
                textField.resignFirstResponder()
                self.entityTextFied.becomeFirstResponder()
            } else if textField == self.entityTextFied {
                textField.resignFirstResponder()
                self.officeTextFied.becomeFirstResponder()
            } else if textField == self.officeTextFied {
                textField.resignFirstResponder()
                self.controlDigitTextFied.becomeFirstResponder()
            } else if textField == self.controlDigitTextFied {
                textField.resignFirstResponder()
                self.accountNumberTextFied.becomeFirstResponder()
            } else if textField == self.accountNumberTextFied {
                textField.resignFirstResponder()
                self.balanceTextFied.becomeFirstResponder()
            } else if textField == self.balanceTextFied {
                self.view.endEditing(true)
                self.onUpdateOrSave()
            }
        })
        return true;
    }

}

// MARK: - ValidationDelegate implementation for NewBankAccountViewController
extension NewBankAccountViewController: ValidationDelegate {
    
    // MARK: Register the required fields
    func registerFieldsInValidator() {
        let requiredString = NSLocalizedString("common.validator.required", comment: "The required field message")
        customValidator.registerField(descriptionTextField, errorLabel: descriptionErrorLabel, rules: [RequiredRule(message: NSLocalizedString("bankAccounts.requiredDescription", comment: "The required description message"))])
        customValidator.registerField(entityTextFied, errorLabel: entityErrorLabel, rules: [RequiredRule(message: requiredString), DigitRule(length: 4)])
        customValidator.registerField(officeTextFied, errorLabel: officeErrorLabel, rules: [RequiredRule(message: requiredString), DigitRule(length: 4)])
        customValidator.registerField(controlDigitTextFied, errorLabel: controlDigitErrorLabel, rules: [RequiredRule(message: requiredString), DigitRule(length: 2)])
        customValidator.registerField(accountNumberTextFied, errorLabel: accountNumberErrorLabel, rules: [RequiredRule(message: requiredString), DigitRule(length: 10)])
        customValidator.registerField(balanceTextFied, errorLabel: balanceErrorLabel, rules: [RequiredRule(message: requiredString), DecimalRule()])
        customValidator.unregisterField(ibanTextFied)
    }
    
    // MARK: Method called when validation failed
    func validationFailed(errors:[UITextField:ValidationError]) {
        customValidator.validationFailed(errors)
    }

    // MARK: Method called when form validation is succesfull
    func validationSuccessful() {
        if let _  = bankAccount {
            updateBankAccount()
        } else {
            createBankAccount()
        }
    }
}

// MARK: - API Request
extension NewBankAccountViewController {
    
    // MARK: Create a bank account in the APP calling to diexpensesAPI
    func createBankAccount() {
        var ibanTrim : String? = ibanTextFied.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if ibanTrim == "" {
            ibanTrim = nil
        }
        
        let bankAccount = BankAccount(iban: ibanTrim, entity: entityTextFied.text!, office: officeTextFied.text!, controlDigit: controlDigitTextFied.text!, accountNumber: accountNumberTextFied.text!, balance: Diexpenses.formatDecimalValue(string: balanceTextFied.text!), description: descriptionTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
        
        let url = String.localizedStringWithFormat(Constants.API.CREATE_BANK_ACCOUNT_URL, Diexpenses.user.id)
        let bankAccountJson = JsonUtils.JSONStringify(bankAccount.toJSON()!, prettyPrinted: true)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.POST.rawValue, body: bankAccountJson, completionHandler: {
            data, response, error in
            
            if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: 30) {
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.BANK_ACCOUNTS_CHANGED, object: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    // MARK: Update a bank account in the APP calling to diexpensesAPI
    func updateBankAccount() {
        var ibanTrim : String? = ibanTextFied.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if ibanTrim == "" {
            ibanTrim = nil
        }
        
        let newBankAccount = BankAccount(id: bankAccount.id, iban: ibanTrim, entity: entityTextFied.text!, office: officeTextFied.text!, controlDigit: controlDigitTextFied.text!, accountNumber: accountNumberTextFied.text!, balance: Diexpenses.formatDecimalValue(string: balanceTextFied.text!), description: descriptionTextField.text!)
        
        let url = String.localizedStringWithFormat(Constants.API.UD_BANK_ACCOUNT_URL, Diexpenses.user.id, newBankAccount.id)
        let newBankAccountJson = JsonUtils.JSONStringify(newBankAccount.toJSON()!, prettyPrinted: true)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.PUT.rawValue, body: newBankAccountJson, completionHandler: {
            data, response, error in
            
            if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: 39) {
                Notificator.fireNotification(notificationName: Constants.Notifications.BANK_ACCOUNTS_CHANGED)
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
        })
    }
}
