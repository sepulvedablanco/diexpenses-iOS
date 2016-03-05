//
//  MovementsKindsViewController.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 6/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit
import Gloss

class ExpensesKindsViewController: UIViewController {
    
    static let noData = NSLocalizedString("common.noData", comment: "The no data common message")
    static let loadingData = NSLocalizedString("common.loadingData", comment: "The loading data message")
    static let selectKind = NSLocalizedString("expenseKind.select", comment: "The select kind message")
    static let selectSubkind = NSLocalizedString("expenseSubkind.select", comment: "The select subkind message")
    static let selectKindFirst = NSLocalizedString("expenseSubkind.selectKind", comment: "The select kind first message")

    var expensesKinds : [ExpenseKind] = [ExpenseKind(description: loadingData)]
    var expensesSubKinds : [ExpenseKind] = [ExpenseKind(description: loadingData)]
    
    var kindSelected: ExpenseKind!
    var subkindSelected: ExpenseKind!

    @IBOutlet weak var kindTextField: UITextField!
    var expensesKindsCustomPicker: CustomPicker!

    @IBOutlet weak var subkindTextField: UITextField!
    var subKindsCustomPicker: CustomPicker!

    @IBOutlet weak var editKindButton: UIButton!
    @IBOutlet weak var deleteKindButton: UIButton!
    
    @IBOutlet weak var newSubkindButton: UIButton!
    @IBOutlet weak var editSubkindButton: UIButton!
    @IBOutlet weak var deleteSubkindButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configureCustomPickers()
        
        setAutoSizeButtons()
        setEnabledKindButtons(false)
        setEnabledSubkindButtons(false, enabledNewSubkindButton: false)
        
        // Performing times
        loadExpensesKinds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ExpensesKindsViewController {
    
    @IBAction func onNewKind() {
        createAlert(NSLocalizedString("expenseKind.new", comment: "The new expense kind message"), message: NSLocalizedString("expenseKind.new.message", comment: "The new expense kind description"), actionButtonMessage: NSLocalizedString("common.save", comment: "The common message save"), expenseKind: nil, operation: .NEW_KIND)
    }
    
    @IBAction func onEditKind() {
        if let kind = kindSelected {
            createAlert(NSLocalizedString("expenseKind.edit", comment: "The edit expense kind message"), message: NSLocalizedString("expenseKind.edit.message", comment: "The edit expense kind description"), actionButtonMessage: NSLocalizedString("common.update", comment: "The common message update"), expenseKind: kind, operation: .EDIT_KIND)
        }
    }
    
    @IBAction func onDeleteKind() {
        if let kind = kindSelected {
            createAlert(NSLocalizedString("expenseKind.delete", comment: "The delete expense kind message"), message: String.localizedStringWithFormat(NSLocalizedString("expenseKind.delete.message", comment: "The delete expense kind description"), kindSelected.description), actionButtonMessage: NSLocalizedString("common.delete", comment: "The common message delete"), expenseKind: kind, operation: .DELETE_KIND)
        }
    }
    
    @IBAction func onNewSubkind() {
        if let _ = kindSelected {
            createAlert(NSLocalizedString("expenseSubkind.new", comment: "The new expense subkind message"), message: NSLocalizedString("expenseSubkind.new.message", comment: "The new expense subkind description"), actionButtonMessage: NSLocalizedString("common.save", comment: "The common message save"), expenseKind: nil, operation: .NEW_SUBKIND)
        }
    }
    
    @IBAction func onEditSubkind() {
        if let subkind = subkindSelected {
            createAlert(NSLocalizedString("expenseSubkind.edit", comment: "The edit expense subkind message"), message: NSLocalizedString("expenseSubkind.edit.message", comment: "The edit expense subkind description"), actionButtonMessage: NSLocalizedString("common.update", comment: "The common message update"), expenseKind: subkind, operation: .EDIT_SUBKIND)
        }
    }
    
    @IBAction func onDeleteSubkind() {
        if let subkind = subkindSelected {
            createAlert(NSLocalizedString("expenseSubkind.delete", comment: "The delete expense subkind message"), message: String.localizedStringWithFormat(NSLocalizedString("expenseSubkind.delete.message", comment: "The delete expense subkind description"), subkindSelected.description), actionButtonMessage: NSLocalizedString("common.delete", comment: "The common message delete"), expenseKind: subkind, operation: .DELETE_SUBKIND)
        }
    }
    
    func createAlert(title: String, message: String, actionButtonMessage: String, var expenseKind: ExpenseKind?, operation: KindsOperations) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        var style: UIAlertActionStyle = .Destructive
        if operation != .DELETE_KIND && operation != .DELETE_SUBKIND {
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.text = expenseKind?.description
            })
            style = .Default
        }
        
        alert.addAction(UIAlertAction(title: actionButtonMessage, style: style, handler: {
            (action) -> Void in
            if operation == .DELETE_KIND {
                self.deleteKind((expenseKind?.id)!)
                return
            }
            if operation == .DELETE_SUBKIND {
                let currentKind = self.expensesKinds[self.expensesKindsCustomPicker.picker.selectedRowInComponent(0)]
                self.deleteSubkind(currentKind.id, subkindId: (expenseKind?.id)!)
                return
            }
            
            let textField = alert.textFields![0] as UITextField
            if let text = textField.text {
                if "" == text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) {
                    // textField.layer.borderColor = UIColor.redColor().CGColor
                    let alert = UIAlertController(title: NSLocalizedString("common.error", comment: "The error title"), message: "Debes introducir un valor obligatoriamente XXX", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("common.accept", comment: "The common accept message"), style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
            }
            
            
            if operation == .NEW_KIND {
                self.createKind(textField.text!)
                return
            }
            if operation == .NEW_SUBKIND {
                let currentKind = self.expensesKinds[self.expensesKindsCustomPicker.picker.selectedRowInComponent(0)]
                self.createSubkind(currentKind.id, value: textField.text!)
                return
            }
            if operation == .EDIT_KIND {
                expenseKind?.description = textField.text!
                self.editKind(expenseKind!)
                return
            }
            if operation == .EDIT_SUBKIND {
                let currentKind = self.expensesKinds[self.expensesKindsCustomPicker.picker.selectedRowInComponent(0)]
                expenseKind?.description = textField.text!
                self.editSubkind(currentKind.id, expenseSubkind: expenseKind!)
                return
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.cancel", comment: "The common cancel message"), style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension ExpensesKindsViewController {
    
    func setAutoSizeButtons() {
        newSubkindButton.titleLabel!.adjustsFontSizeToFitWidth = true;
        editSubkindButton.titleLabel!.adjustsFontSizeToFitWidth = true;
        deleteSubkindButton.titleLabel!.adjustsFontSizeToFitWidth = true;
    }
    
    func setEnabledKindButtons(enabled: Bool) {
        editKindButton.enabled = enabled
        editKindButton.alpha = enabled ? 1.0 : 0.5
        deleteKindButton.enabled = enabled
        deleteKindButton.alpha = enabled ? 1.0 : 0.5
    }
    
    func setEnabledSubkindButtons(enabled: Bool, enabledNewSubkindButton: Bool = true) {
        newSubkindButton.enabled = enabledNewSubkindButton
        newSubkindButton.alpha = enabledNewSubkindButton ? 1.0 : 0.5
        editSubkindButton.enabled = enabled
        editSubkindButton.alpha = enabled ? 1.0 : 0.5
        deleteSubkindButton.enabled = enabled
        deleteSubkindButton.alpha = enabled ? 1.0 : 0.5
    }
    
}

extension ExpensesKindsViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == expensesKindsCustomPicker.picker {
            return self.expensesKinds[row].description
        }
        if pickerView == subKindsCustomPicker.picker {
            return self.expensesSubKinds[row].description
        }
        return nil
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == expensesKindsCustomPicker.picker {
            loadExpensesSubkinds(self.expensesKinds[row].id)
        }
    }

}

extension ExpensesKindsViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == expensesKindsCustomPicker.picker {
            return self.expensesKinds.count
        }
        if pickerView == subKindsCustomPicker.picker {
            return self.expensesSubKinds.count
        }
        return 0
    }
}

extension ExpensesKindsViewController {
    
    func loadExpensesKinds(kindDescriptionToSet: String?=nil) {

        let url = String.localizedStringWithFormat(Constants.API.LIST_FIN_MOV_TYPES, Diexpenses.user.id)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            guard let _ =  data else {
                NSLog("Without Internet connection")
                return
            }
            
            do {
                let expensesKindsJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))  as? NSArray)!
                let newExpensesKinds = ExpenseKind.modelsFromJSONArray(expensesKindsJson as! [JSON])!
                if newExpensesKinds.isEmpty {
                    self.expensesKinds = [ExpenseKind(description: ExpensesKindsViewController.noData)]
                } else {
                    self.expensesKinds = newExpensesKinds.sort{$0.description < $1.description}
                    if let description = kindDescriptionToSet {
                        self.kindSelected = self.expensesKinds.filter{$0.description == description}.first
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.onSubkindUnselected()
                            self.expensesKindsCustomPicker.doCommonOperations(self.kindSelected.description)
                        })
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.expensesKindsCustomPicker.picker.reloadAllComponents()
                })
            } catch let error as NSError {
                NSLog("Error getting expenses kinds: \(error.localizedDescription)")
            }
        })
    }
    
    func createKind(value: String) {
        
        let url = String.localizedStringWithFormat(Constants.API.CREATE_FIN_MOV_TYPES, Diexpenses.user.id)
        let expenseKind = ExpenseKind(description: value)
        let expenseKindJson = JsonUtils.JSONStringify(expenseKind.toJSON()!, prettyPrinted: true)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.POST.rawValue, body: expenseKindJson, completionHandler: {
            data, response, error in
            
            if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: 60) {
                self.loadExpensesKinds(value)
            }
        })
    }
    
    func editKind(expenseKind: ExpenseKind) {
        
        let url = String.localizedStringWithFormat(Constants.API.UD_FIN_MOV_TYPES, Diexpenses.user.id, expenseKind.id)
        let expenseKindJson = JsonUtils.JSONStringify(expenseKind.toJSON()!, prettyPrinted: true)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.PUT.rawValue, body: expenseKindJson, completionHandler: {
            data, response, error in
            
            if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: 66) {
                self.onKindEdited(expenseKind)
            }
        })
    }
    
    func deleteKind(kindId: NSNumber) {
        
        let url = String.localizedStringWithFormat(Constants.API.UD_FIN_MOV_TYPES, Diexpenses.user.id, kindId)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.DELETE.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: 71) {
                self.onKindUnselected()
            }
        })
    }
}

extension ExpensesKindsViewController {
    
    func loadExpensesSubkinds(kindId: NSNumber, subkindDescriptionToSet: String?=nil) {
        
        let url = String.localizedStringWithFormat(Constants.API.LIST_FIN_MOV_SUBTYPES, kindId)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            guard let _ =  data else {
                NSLog("Without Internet connection")
                return
            }
            
            do {
                let expensesSubkindsJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))  as? NSArray)!
                let newExpensesSubkinds = ExpenseKind.modelsFromJSONArray(expensesSubkindsJson as! [JSON])!
                if newExpensesSubkinds.isEmpty {
                    self.expensesSubKinds = [ExpenseKind(description: ExpensesKindsViewController.noData)]
                } else {
                    self.expensesSubKinds = newExpensesSubkinds.sort{$0.description < $1.description}

                    if let description = subkindDescriptionToSet {
                        self.subkindSelected = self.expensesSubKinds.filter{$0.description == description}.first
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.subKindsCustomPicker.doCommonOperations(self.subkindSelected.description)
                        })
                    }
                }

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.setEnabledSubkindButtons(newExpensesSubkinds.count != 0)
                    self.subKindsCustomPicker.picker.reloadAllComponents()
                })
                
            } catch let error as NSError {
                NSLog("Error getting expenses subkinds: \(error.localizedDescription)")
            }
        })
    }
    
    func createSubkind(kindId: NSNumber, value: String) {
        
        let url = String.localizedStringWithFormat(Constants.API.CREATE_FIN_MOV_SUBTYPES, kindId)
        let expenseSubkind = ExpenseKind(description: value)
        let expenseSubkindJson = JsonUtils.JSONStringify(expenseSubkind.toJSON()!, prettyPrinted: true)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.POST.rawValue, body: expenseSubkindJson, completionHandler: {
            data, response, error in
            
            if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: 90) {
                self.loadExpensesSubkinds(kindId, subkindDescriptionToSet: value)
            }
        })
    }
    
    func editSubkind(kindId: NSNumber, expenseSubkind: ExpenseKind) {

        let url = String.localizedStringWithFormat(Constants.API.UD_FIN_MOV_SUBTYPES, kindId, expenseSubkind.id)
        let expenseSubkindJson = JsonUtils.JSONStringify(expenseSubkind.toJSON()!, prettyPrinted: true)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.PUT.rawValue, body: expenseSubkindJson, completionHandler: {
            data, response, error in
            
            if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: 99) {
                self.onSubkindEdited(kindId, expenseSubkind: expenseSubkind)
            }
        })
    }
    
    func deleteSubkind(kindId: NSNumber, subkindId: NSNumber) {

        let url = String.localizedStringWithFormat(Constants.API.UD_FIN_MOV_SUBTYPES, kindId, subkindId)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.DELETE.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: 104) {
                self.onSubkindUnselected()
            }
        })
    }
}

extension ExpensesKindsViewController {
    
    func getBarItems(doneSelector: Selector, cancelSelector: Selector) -> [UIBarButtonItem] {
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("common.cancel", comment: "The common cancel message"), style: .Plain, target: self, action: cancelSelector)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("common.done", comment: "The common done message"), style: .Plain, target: self, action: doneSelector)
        return [cancelButton, spaceButton, doneButton]
    }
    
    func configureCustomPickers() {
        
        expensesKindsCustomPicker = CustomPicker(target: self, uiTextField: kindTextField, items: getBarItems("onKindSelected", cancelSelector: "onCancelKind"))
        expensesKindsCustomPicker.picker.delegate = self
        expensesKindsCustomPicker.picker.dataSource = self
        kindTextField.text = ExpensesKindsViewController.selectKind
        kindTextField.delegate = self
        
        subKindsCustomPicker = CustomPicker(target: self, uiTextField: subkindTextField, items: getBarItems("onSubkindSelected", cancelSelector: "onCancelSubkind"))
        subKindsCustomPicker.picker.delegate = self
        subKindsCustomPicker.picker.dataSource = self
        subkindTextField.enabled = false
        subkindTextField.text = ExpensesKindsViewController.selectKindFirst
        subkindTextField.delegate = self
    }

    func onCancelKind() {
        if let kind = kindSelected {
            expensesKindsCustomPicker.doCommonOperations(kind.description)
        } else {
            expensesKindsCustomPicker.doCommonOperations(ExpensesKindsViewController.selectKind)
        }
    }

    func onCancelSubkind() {
        if let subkind = subkindSelected {
            subKindsCustomPicker.doCommonOperations(subkind.description)
            return
        }
        
        if let _ = kindSelected {
            subKindsCustomPicker.doCommonOperations(ExpensesKindsViewController.selectSubkind)
        } else {
            subKindsCustomPicker.doCommonOperations(ExpensesKindsViewController.selectKindFirst)
        }
    }

    func onKindSelected() {
        let tempKind = expensesKinds[expensesKindsCustomPicker.picker.selectedRowInComponent(0)]
        if let _ = tempKind.id {
            kindSelected = tempKind
            expensesKindsCustomPicker.doCommonOperations(kindSelected.description)
            subKindsCustomPicker.doCommonOperations(ExpensesKindsViewController.selectSubkind)
            setEnabledKindButtons(true)
            setEnabledSubkindButtons(false, enabledNewSubkindButton: true)
            subkindTextField.enabled = true
        }
    }
    
    func onKindEdited(expenseKind: ExpenseKind) {
        self.kindSelected = expenseKind
        dispatch_async(dispatch_get_main_queue(), {
            self.expensesKindsCustomPicker.doCommonOperations(self.kindSelected.description)
        })
        self.loadExpensesKinds()
    }

    /* Fires when a kind is deleted */
    func onKindUnselected() {
        kindSelected = nil
        dispatch_async(dispatch_get_main_queue(), {
            self.expensesKindsCustomPicker.doCommonOperations(ExpensesKindsViewController.selectKind)
            self.subKindsCustomPicker.doCommonOperations(ExpensesKindsViewController.selectKindFirst)
            self.setEnabledKindButtons(false)
            self.setEnabledSubkindButtons(false, enabledNewSubkindButton: false)
            self.subkindTextField.enabled = false
        })
        // Performing times
        loadExpensesKinds()
    }

    func onSubkindSelected() {
        let tempSubkind = expensesSubKinds[subKindsCustomPicker.picker.selectedRowInComponent(0)]
        if let _ = tempSubkind.id {
            subkindSelected = tempSubkind
            subKindsCustomPicker.doCommonOperations(subkindSelected.description)
            setEnabledSubkindButtons(true)
        }
    }
    
    func onSubkindEdited(kindId: NSNumber, expenseSubkind: ExpenseKind) {
        self.subkindSelected = expenseSubkind
        dispatch_async(dispatch_get_main_queue(), {
            self.subKindsCustomPicker.doCommonOperations(self.subkindSelected.description)
        })
        self.loadExpensesSubkinds(kindId)
    }
    
    func onSubkindUnselected() {
        subkindSelected = nil
        dispatch_async(dispatch_get_main_queue(), {
            self.subKindsCustomPicker.doCommonOperations(ExpensesKindsViewController.selectSubkind)
            self.setEnabledSubkindButtons(false)
        })
        // Performing time
        loadExpensesSubkinds(kindSelected.id)
    }
}

extension ExpensesKindsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == kindTextField {
            loadExpensesKinds()
        } else if textField == subkindTextField {
            if let kind = kindSelected {
                loadExpensesSubkinds(kind.id)
            }
        }
    }
}