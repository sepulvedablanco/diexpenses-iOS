//
//  NewMovementViewController.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 7/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit
import Gloss

class NewMovementViewController: UIViewController {
    
    var expensesKinds : [ExpenseKind] = [ExpenseKind(description: ExpensesKindsViewController.noData)]
    var expensesSubKinds : [ExpenseKind] = [ExpenseKind(description: ExpensesKindsViewController.noData)]
    var bankAccounts : [BankAccount] = []

    @IBOutlet weak var expensesSegmentedControl: UISegmentedControl!
    @IBOutlet weak var conceptTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var kindTextField: UITextField!
    var kindsCustomPicker: CustomPicker!

    @IBOutlet weak var subkindTextField: UITextField!
    var subkindsCustomPicker: CustomPicker!

    @IBOutlet weak var bankAccountTextField: UITextField!
    var bankAccountsCustomPicker: CustomPicker!

    @IBOutlet weak var transactionDateTextField: UITextField!
    var transactionDateCustomPicker: CustomDatePicker!

    var selectedKind: ExpenseKind!
    var selectedSubkind: ExpenseKind!
    var selectedBankAccount: BankAccount!
    var selectedDate: NSDate!
    
    @IBAction func onSegmentedActionPushed(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            NSLog("expenses selected")
        } else if sender.selectedSegmentIndex == 1 {
            NSLog("incomes selected")
        }
    }
    
    @IBAction func onCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSave(sender: UIBarButtonItem) {
        let isExpenses = expensesSegmentedControl.selectedSegmentIndex == 0;
        
        let concept = conceptTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if concept.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            createAlert(NSLocalizedString("newMovement.insert.concept", comment: "There enter concept message"))
            return
        }
        
        let amountString = amountTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if amountString == "" {
            createAlert(NSLocalizedString("newMovement.insert.amount", comment: "There enter amount message"))
            return
        }
        
        let amount = Diexpenses.formatDecimalValue(string: amountString)
        guard let _ = selectedKind else {
            createAlert(NSLocalizedString("newMovement.insert.kind", comment: "There select kind message"))
            return
        }
        
        guard let _ = selectedSubkind else {
            createAlert(NSLocalizedString("newMovement.insert.subkind", comment: "There select subkind message"))
            return
        }

        guard let _ = selectedBankAccount else {
            createAlert(NSLocalizedString("newMovement.insert.bankAccount", comment: "There select bank account message"))
            return
        }
        
        let movement = Movement(expense: isExpenses, concept: concept, transactionDate: selectedDate, amount: amount, financialMovementType: selectedKind, financialMovementSubtype: selectedSubkind, bankAccount: selectedBankAccount)
                
        createMovement(movement)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setTextFieldsDelegate()
        configureCustomPickers()
        loadExpensesKinds()
        loadBankAccounts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension NewMovementViewController {
    
    func setTextFieldsDelegate() {
        conceptTextField.delegate = self
        amountTextField.delegate = self
    }
    
    func getBarItems(doneSelector: Selector, cancelSelector: Selector) -> [UIBarButtonItem] {
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("common.cancel", comment: "The common cancel message"), style: .Plain, target: self, action: cancelSelector)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("common.done", comment: "The common done message"), style: .Plain, target: self, action: doneSelector)
        return [cancelButton, spaceButton, doneButton]
    }
    
    func configureCustomPickers() {
        
        kindsCustomPicker = CustomPicker(target: self, uiTextField: kindTextField, items: getBarItems("onKindSelected", cancelSelector: "onCancelKind"))
        kindsCustomPicker.picker.delegate = self
        kindsCustomPicker.picker.dataSource = self
        kindTextField.text = ExpensesKindsViewController.selectKind
        kindTextField.delegate = self
        
        subkindsCustomPicker = CustomPicker(target: self, uiTextField: subkindTextField, items: getBarItems("onSubkindSelected", cancelSelector: "onCancelSubkind"))
        subkindsCustomPicker.picker.delegate = self
        subkindsCustomPicker.picker.dataSource = self
        subkindTextField.enabled = false
        subkindTextField.text = ExpensesKindsViewController.selectKindFirst
        subkindTextField.delegate = self
        
        bankAccountsCustomPicker = CustomPicker(target: self, uiTextField: bankAccountTextField, items: getBarItems("onBankAccountSelected", cancelSelector: "onCancelBankAccount"))
        bankAccountsCustomPicker.picker.delegate = self
        bankAccountsCustomPicker.picker.dataSource = self
        bankAccountTextField.text = NSLocalizedString("newMovement.select.bankAccount", comment: "The select bank account message")
        bankAccountTextField.delegate = self

        transactionDateCustomPicker = CustomDatePicker(target: self, uiTextField: transactionDateTextField, items: getBarItems("onTransactionDateSelected", cancelSelector: "onCancelTransactionDate"))
        transactionDateCustomPicker.picker.datePickerMode = .Date
        transactionDateTextField.text = Diexpenses.formatDate(NSDate(), format: Diexpenses.DAY_MONTH_YEAR)
        transactionDateTextField.delegate = self
        selectedDate = transactionDateCustomPicker.picker.date
    }
    
}

extension NewMovementViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == kindTextField {
            loadExpensesKinds()
        } else if textField == subkindTextField && selectedKind != nil {
            loadExpensesSubkinds(selectedKind.id)
        } else if textField == bankAccountTextField {
            loadBankAccounts()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dispatch_async(dispatch_get_main_queue(), {
            if textField == self.conceptTextField {
                textField.resignFirstResponder()
                self.amountTextField.becomeFirstResponder()
            }
            /*else if textField == self.amountTextField {
                textField.resignFirstResponder()
                self.view.endEditing(true)
            }*/
        })
        return true;
    }

}

extension NewMovementViewController {

    func onKindSelected() {
        let tempKind = expensesKinds[kindsCustomPicker.picker.selectedRowInComponent(0)]
        if let _ = tempKind.id {
            selectedKind = tempKind
            kindsCustomPicker.doCommonOperations(tempKind.description)
            subkindsCustomPicker.doCommonOperations(ExpensesKindsViewController.selectSubkind)
            subkindTextField.enabled = true
        }

    }
    
    func onCancelKind() {
        if let kind = selectedKind {
            kindsCustomPicker.doCommonOperations(kind.description)
        } else {
            kindsCustomPicker.doCommonOperations(ExpensesKindsViewController.selectKind)
        }
    }
    
    func onSubkindSelected() {
        let tempSubkind = expensesSubKinds[subkindsCustomPicker.picker.selectedRowInComponent(0)]
        if let _ = tempSubkind.id {
            selectedSubkind = tempSubkind
            subkindsCustomPicker.doCommonOperations(tempSubkind.description)
        }
    }
    
    func onCancelSubkind() {
        if let subkind = selectedSubkind {
            subkindsCustomPicker.doCommonOperations(subkind.description)
            return
        }
        
        if let _ = selectedKind {
            subkindsCustomPicker.doCommonOperations(ExpensesKindsViewController.selectKindFirst)
        } else {
            subkindsCustomPicker.doCommonOperations(ExpensesKindsViewController.selectSubkind)
        }

    }
    
    func onBankAccountSelected() {
        let tempBankAccount = bankAccounts[bankAccountsCustomPicker.picker.selectedRowInComponent(0)]
        if let _ = tempBankAccount.id {
            selectedBankAccount = tempBankAccount
            bankAccountsCustomPicker.doCommonOperations(tempBankAccount.description)
        }
    }
    
    func onCancelBankAccount() {
        if let bankAccount = selectedBankAccount {
            bankAccountsCustomPicker.doCommonOperations(bankAccount.description)
        } else {
            bankAccountsCustomPicker.doCommonOperations(NSLocalizedString("newMovement.select.bankAccount", comment: "The select bank account message"))
        }
    }
    
    func onTransactionDateSelected() {
        selectedDate = transactionDateCustomPicker.picker.date
        transactionDateCustomPicker.doCommonOperations(Diexpenses.formatDate(selectedDate, format: Diexpenses.DAY_MONTH_YEAR))
    }
    
    func onCancelTransactionDate() {
        if let date = selectedDate {
            transactionDateCustomPicker.doCommonOperations(Diexpenses.formatDate(date, format: Diexpenses.DAY_MONTH_YEAR))
        } else {
            transactionDateCustomPicker.doCommonOperations(Diexpenses.formatDate(NSDate(), format: Diexpenses.DAY_MONTH_YEAR))
        }
    }
    
}

extension NewMovementViewController {
    
    func createAlert(message: String) {
        let alertLoginError = UIAlertController(title: NSLocalizedString("common.error", comment: "The error title"), message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertLoginError.addAction(UIAlertAction(title: NSLocalizedString("common.close", comment: "The close button"), style: .Default, handler: nil))
        self.presentViewController(alertLoginError, animated: true, completion: nil)
    }
}

extension NewMovementViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == kindsCustomPicker.picker {
            return self.expensesKinds[row].description
        }
        if pickerView == subkindsCustomPicker.picker {
            return self.expensesSubKinds[row].description
        }
        if pickerView == bankAccountsCustomPicker.picker {
            if bankAccounts.isEmpty {
                return NSLocalizedString("common.noBankAccounts", comment: "The no bank accounts message")
            }
            return self.bankAccounts[row].description
        }
        return nil
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == kindsCustomPicker.picker {
            if let id = self.expensesKinds[row].id {
                loadExpensesSubkinds(id)
            }
        }
    }

}

extension NewMovementViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == kindsCustomPicker.picker {
            return self.expensesKinds.count
        }
        if pickerView == subkindsCustomPicker.picker {
            return self.expensesSubKinds.count
        }
        if pickerView == bankAccountsCustomPicker.picker {
            if bankAccounts.isEmpty {
                return 1
            }
            return self.bankAccounts.count
        }
        return 0
    }
}

extension NewMovementViewController {
 
    func loadExpensesKinds() {
        
        let url = String.localizedStringWithFormat(Constants.API.LIST_FIN_MOV_TYPES, Diexpenses.user.id)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d =  data {
                do {
                    let expensesKindsJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions(rawValue: 0))  as? NSArray)!
                    let newExpensesKinds = ExpenseKind.modelsFromJSONArray(expensesKindsJson as! [JSON])!
                    if newExpensesKinds.isEmpty {
                        self.expensesKinds = [ExpenseKind(description: ExpensesKindsViewController.noData)]
                    } else {
                        self.expensesKinds = newExpensesKinds
                        self.loadExpensesSubkinds(self.expensesKinds[0].id)
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.kindsCustomPicker.picker.reloadAllComponents()
                    })
                } catch let error as NSError {
                    NSLog("Error getting expenses kinds: \(error.localizedDescription)")
                }
            } else {
                NSLog("Without Internet connection")
            }
        })
    }

    func loadExpensesSubkinds(kindId: NSNumber) {
        
        let url = String.localizedStringWithFormat(Constants.API.LIST_FIN_MOV_SUBTYPES, kindId)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d =  data {
                do {
                    let expensesSubkindsJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions(rawValue: 0))  as? NSArray)!
                    let newExpensesSubkinds = ExpenseKind.modelsFromJSONArray(expensesSubkindsJson as! [JSON])!
                    if newExpensesSubkinds.count == 0 {
                        self.expensesSubKinds = [ExpenseKind(description: ExpensesKindsViewController.noData)]
                    } else {
                        self.expensesSubKinds = newExpensesSubkinds
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.subkindsCustomPicker.picker.reloadAllComponents()
                    })
                    
                } catch let error as NSError {
                    NSLog("Error getting expenses subkinds: \(error.localizedDescription)")
                }
            } else {
                NSLog("Without Internet connection")
            }
        })
    }
    
    func loadBankAccounts() {
        
        let bankAccountsURL = String.localizedStringWithFormat(Constants.API.LIST_BANK_ACCOUNTS_URL, Diexpenses.user.id)
        Diexpenses.doRequest(bankAccountsURL, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d =  data {
                do {
                    let bankAccountsJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions(rawValue: 0))  as? NSArray)!
                    
                    let lstBankAccounts = BankAccount.modelsFromJSONArray(bankAccountsJson as! [JSON])!
                    if lstBankAccounts.isEmpty {
                        //    self.bankAccounts = [BankAccount(description: ExpensesKindsViewController.noData)]
                    }else {
                        self.bankAccounts = lstBankAccounts
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.bankAccountsCustomPicker.picker.reloadAllComponents()
                    })
                } catch let error as NSError {
                    NSLog("An error has occurred: \(error.localizedDescription)")
                }
            } else {
                NSLog("Without Internet connection")
            }
        })
    }
    
    func createMovement(movement: Movement) {
        
        guard let _ = Diexpenses.user.id else {
            NSLog("Without Internet connection or login not performed")
            return
        }
        
        let newMovementJson = JsonUtils.JSONStringify(movement.toJSON()!, prettyPrinted: true)
        
        let newMovementParsed1 = newMovementJson.stringByReplacingOccurrencesOfString("[", withString: "{")
        let newMovementParsed2 = newMovementParsed1.stringByReplacingOccurrencesOfString("]", withString: "}")

        let createMovementURL = String.localizedStringWithFormat(Constants.API.CREATE_MOVEMENT_URL, Diexpenses.user.id)
        Diexpenses.doRequest(createMovementURL, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.POST.rawValue, body: newMovementParsed2, completionHandler: {
            data, response, error in
            
            if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: 127) {
                NSNotificationCenter.defaultCenter().postNotificationName("refreshMovementsTableView", object: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }

}