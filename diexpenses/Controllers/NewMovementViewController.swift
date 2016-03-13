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
    
    static let noData = NSLocalizedString("common.noData", comment: "The no data common message")
    static let loadingData = NSLocalizedString("common.loadingData", comment: "The loading data message")
    static let selectKind = NSLocalizedString("expenseKind.select", comment: "The select kind message")
    static let selectSubkind = NSLocalizedString("expenseSubkind.select", comment: "The select subkind message")
    static let selectKindFirst = NSLocalizedString("expenseSubkind.selectKind", comment: "The select kind first message")

    var expensesKinds : [ExpenseKind] = [ExpenseKind(description: noData)]
    var expensesSubKinds : [ExpenseKind] = [ExpenseKind(description: noData)]
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
    
    @IBAction func onCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSave(sender: UIBarButtonItem) {
        let isExpenses = expensesSegmentedControl.selectedSegmentIndex == 0;
        
        let concept = conceptTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if concept.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
            Diexpenses.showError(self, message: NSLocalizedString("newMovement.insert.concept", comment: "There enter concept message"))
            return
        }
        
        let amountString = amountTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if amountString == "" {
            Diexpenses.showError(self, message: NSLocalizedString("newMovement.insert.amount", comment: "There enter amount message"))
            return
        }
        
        let amount = Diexpenses.formatDecimalValue(string: amountString)
        guard let _ = selectedKind else {
            Diexpenses.showError(self, message: NSLocalizedString("newMovement.insert.kind", comment: "There select kind message"))
            return
        }
        
        guard let _ = selectedSubkind else {
            Diexpenses.showError(self, message: NSLocalizedString("newMovement.insert.subkind", comment: "There select subkind message"))
            return
        }

        guard let _ = selectedBankAccount else {
            Diexpenses.showError(self, message: NSLocalizedString("newMovement.insert.bankAccount", comment: "There select bank account message"))
            return
        }
        
        let movement = Movement(expense: isExpenses, concept: concept, transactionDate: selectedDate, amount: amount, financialMovementType: selectedKind, financialMovementSubtype: selectedSubkind, bankAccount: selectedBankAccount)
                
        createMovement(movement)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        initVC()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - Extension for legacy operations
extension NewMovementViewController {
    
    // MARK: Initialize the View Controller
    func initVC() {
        setTextFieldsDelegate()
        configureCustomPickers()
        loadExpensesKinds()
        loadBankAccounts()
    }
}

// MARK: - Custom pickers operations
extension NewMovementViewController {
    
    // MARK: Configure custom pickers
    func configureCustomPickers() {
        
        kindsCustomPicker = CustomPicker(target: self, uiTextField: kindTextField, items: getBarItems("onKindSelected", cancelSelector: "onCancelKind"))
        kindsCustomPicker.picker.delegate = self
        kindsCustomPicker.picker.dataSource = self
        kindTextField.text = NewMovementViewController.selectKind
        kindTextField.delegate = self
        
        subkindsCustomPicker = CustomPicker(target: self, uiTextField: subkindTextField, items: getBarItems("onSubkindSelected", cancelSelector: "onCancelSubkind"))
        subkindsCustomPicker.picker.delegate = self
        subkindsCustomPicker.picker.dataSource = self
        subkindTextField.enabled = false
        subkindTextField.text = NewMovementViewController.selectKindFirst
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

    // MARK: This method create the UIBarButtonItem wich are contained inside the custom pickers
    func getBarItems(doneSelector: Selector, cancelSelector: Selector) -> [UIBarButtonItem] {
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("common.cancel", comment: "The common cancel message"), style: .Plain, target: self, action: cancelSelector)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("common.done", comment: "The common done message"), style: .Plain, target: self, action: doneSelector)
        return [cancelButton, spaceButton, doneButton]
    }

    // MARK: This method is called when some kind of custom picker is selected
    func onKindSelected() {
        let tempKind = expensesKinds[kindsCustomPicker.picker.selectedRowInComponent(0)]
        if let _ = tempKind.id {
            selectedKind = tempKind
            kindsCustomPicker.doCommonOperations(tempKind.description)
            subkindsCustomPicker.doCommonOperations(NewMovementViewController.selectSubkind)
            subkindTextField.enabled = true
        }
    }
    
    // MARK: This method is called when cancel button of kind custom picker is selected
    func onCancelKind() {
        if let kind = selectedKind {
            kindsCustomPicker.doCommonOperations(kind.description)
        } else {
            kindsCustomPicker.doCommonOperations(NewMovementViewController.selectKind)
        }
    }
    
    // MARK: This method is called when some subkind of custom picker is selected
    func onSubkindSelected() {
        let tempSubkind = expensesSubKinds[subkindsCustomPicker.picker.selectedRowInComponent(0)]
        if let _ = tempSubkind.id {
            selectedSubkind = tempSubkind
            subkindsCustomPicker.doCommonOperations(tempSubkind.description)
        }
    }
    
    // MARK: This method is called when cancel button of subkind custom picker is selected
    func onCancelSubkind() {
        // If previous subkind is selected, reselect
        if let subkind = selectedSubkind {
            subkindsCustomPicker.doCommonOperations(subkind.description)
            return
        }
        
        if let _ = selectedKind {
            subkindsCustomPicker.doCommonOperations(NewMovementViewController.selectKindFirst)
        } else {
            subkindsCustomPicker.doCommonOperations(NewMovementViewController.selectSubkind)
        }
        
    }
    
    // MARK: This method is called when some bank account of custom picker is selected
    func onBankAccountSelected() {
        let tempBankAccount = bankAccounts[bankAccountsCustomPicker.picker.selectedRowInComponent(0)]
        if let _ = tempBankAccount.id {
            selectedBankAccount = tempBankAccount
            bankAccountsCustomPicker.doCommonOperations(tempBankAccount.description)
        }
    }
    
    // MARK: This method is called when cancel button of bank accounts custom picker is selected
    func onCancelBankAccount() {
        if let bankAccount = selectedBankAccount {
            bankAccountsCustomPicker.doCommonOperations(bankAccount.description)
        } else {
            bankAccountsCustomPicker.doCommonOperations(NSLocalizedString("newMovement.select.bankAccount", comment: "The select bank account message"))
        }
    }
    
    // MARK: This method is called when some date of custom picker is selected
    func onTransactionDateSelected() {
        selectedDate = transactionDateCustomPicker.picker.date
        transactionDateCustomPicker.doCommonOperations(Diexpenses.formatDate(selectedDate, format: Diexpenses.DAY_MONTH_YEAR))
    }
    
    // MARK: This method is called when cancel button of transaction date custom picker is selected
    func onCancelTransactionDate() {
        if let date = selectedDate {
            transactionDateCustomPicker.doCommonOperations(Diexpenses.formatDate(date, format: Diexpenses.DAY_MONTH_YEAR))
        } else {
            transactionDateCustomPicker.doCommonOperations(Diexpenses.formatDate(NSDate(), format: Diexpenses.DAY_MONTH_YEAR))
        }
    }
}

// MARK: - UITextFieldDelegate implementation for NewMovementViewController
extension NewMovementViewController: UITextFieldDelegate {
    
    // MARK: Set the UITextFields form delegate
    func setTextFieldsDelegate() {
        conceptTextField.delegate = self
        amountTextField.delegate = self
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == kindTextField {
            loadExpensesKinds()
        } else if textField == subkindTextField {
            if let kind = selectedKind {
                loadExpensesSubkinds(kind.id)
            }
        } else if textField == bankAccountTextField {
            loadBankAccounts()
        }
    }
    
    // MARK: Method called when the user push Next in the keyboard
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

// MARK: - UIPickerViewDelegate implementation for NewMovementViewController
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

// MARK: - UIPickerViewDataSource implementation for NewMovementViewController
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

// MARK: - API Request
extension NewMovementViewController {
 
    // MARK: Load the expenses kinds calling to diexpensesAPI
    func loadExpensesKinds() {
        
        let url = String.localizedStringWithFormat(Constants.API.LIST_FIN_MOV_TYPES, Diexpenses.user.id)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d =  data {
                do {
                    let expensesKindsJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions(rawValue: 0))  as? NSArray)!
                    let newExpensesKinds = ExpenseKind.modelsFromJSONArray(expensesKindsJson as! [JSON])!
                    if newExpensesKinds.isEmpty {
                        self.expensesKinds = [ExpenseKind(description: NewMovementViewController.noData)]
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

    // MARK: Load the expenses subkinds calling to diexpensesAPI
    func loadExpensesSubkinds(kindId: NSNumber) {
        
        let url = String.localizedStringWithFormat(Constants.API.LIST_FIN_MOV_SUBTYPES, kindId)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d =  data {
                do {
                    let expensesSubkindsJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions(rawValue: 0))  as? NSArray)!
                    let newExpensesSubkinds = ExpenseKind.modelsFromJSONArray(expensesSubkindsJson as! [JSON])!
                    if newExpensesSubkinds.count == 0 {
                        self.expensesSubKinds = [ExpenseKind(description: NewMovementViewController.noData)]
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
    
    // MARK: Load the bank accounts calling to diexpensesAPI
    func loadBankAccounts() {
        
        let bankAccountsURL = String.localizedStringWithFormat(Constants.API.LIST_BANK_ACCOUNTS_URL, Diexpenses.user.id)
        Diexpenses.doRequest(bankAccountsURL, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d =  data {
                do {
                    let bankAccountsJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions(rawValue: 0))  as? NSArray)!
                    
                    let lstBankAccounts = BankAccount.modelsFromJSONArray(bankAccountsJson as! [JSON])!
                    if lstBankAccounts.isEmpty {
                        //    self.bankAccounts = [BankAccount(description: NewMovementViewController.noData)]
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
    
    // MARK: Create a movement calling to diexpensesAPI
    func createMovement(movement: Movement) {
        
        let newMovementJson = JsonUtils.JSONStringify(movement.toJSON()!, prettyPrinted: true)
        
        let newMovementParsed1 = newMovementJson.stringByReplacingOccurrencesOfString("[", withString: "{")
        let newMovementParsed2 = newMovementParsed1.stringByReplacingOccurrencesOfString("]", withString: "}")

        let createMovementURL = String.localizedStringWithFormat(Constants.API.CREATE_MOVEMENT_URL, Diexpenses.user.id)
        Diexpenses.doRequest(createMovementURL, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.POST.rawValue, body: newMovementParsed2, completionHandler: {
            data, response, error in
            
            if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: 127) {
                Notificator.fireNotification(expense: movement.expense)
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
        })
    }

}