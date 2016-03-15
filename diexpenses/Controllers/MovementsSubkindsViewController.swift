//
//  MovementsSubkindsViewController.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 6/3/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit
import Gloss

class MovementSubkindsViewController: UIViewController {
    
    var expenseKind: ExpenseKind!
    var expensesSubkinds: [ExpenseKind] = []
    
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var movementesSubkindsTableView: UITableView!
    
    @IBAction func onBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onNewMovementSubkind(sender: UIBarButtonItem) {
        createAlert(NSLocalizedString("expenseSubkind.new", comment: "The new expense subkind message"), message: NSLocalizedString("expenseSubkind.new.message", comment: "The new expense subkind description"), actionButtonMessage: NSLocalizedString("common.save", comment: "The common message save"), expenseKind: nil, operation: .NEW_SUBKIND)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        initVC()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - Extension for legacy operations
extension MovementSubkindsViewController {
    
    // MARK: Initialize the View Controller
    func initVC() {
        self.navigationItem.title = expenseKind.description
        self.refreshControl = Diexpenses.createRefreshControl(self, actionName: "refreshMovementsSubkinds:")
        movementesSubkindsTableView.addSubview(self.refreshControl)
        self.loadMovementsSubkinds()
    }
    
    // MARK: Refresh the movements subkinds table data
    func refreshMovementsSubkinds(refreshControl: UIRefreshControl) {
        loadMovementsSubkinds()
        refreshControl.endRefreshing()
    }
    
    // MARK: Create a custom alert based on the kind of operation
    func createAlert(title: String, message: String, actionButtonMessage: String, var expenseKind: ExpenseKind?, operation: KindsOperations) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        var style: UIAlertActionStyle = .Destructive
        if operation != .DELETE_SUBKIND {
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.text = expenseKind?.description
            })
            style = .Default
        }
        
        alert.addAction(UIAlertAction(title: actionButtonMessage, style: style, handler: {
            (action) -> Void in
            if operation == .DELETE_SUBKIND {
                self.deleteSubkind(expenseKind!.id)
                return
            }
            
            let textField = alert.textFields![0] as UITextField
            if let text = textField.text {
                if "" == text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) {
                    // textField.layer.borderColor = UIColor.redColor().CGColor
                    let alert = UIAlertController(title: NSLocalizedString("common.error", comment: "The error title"), message: NSLocalizedString("", comment: "The required field title"), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("common.accept", comment: "The common accept message"), style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
            }
            
            if operation == .NEW_SUBKIND {
                self.createSubkind(textField.text!)
                return
            }
            if operation == .EDIT_SUBKIND {
                expenseKind?.description = textField.text!
                self.editSubkind(expenseKind!)
                return
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.cancel", comment: "The common cancel message"), style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate implementation for MovementSubkindsViewController
extension MovementSubkindsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let remove = UITableViewRowAction(style: .Destructive, title: NSLocalizedString("common.delete", comment: "The delete title")) {
            action, index in
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let movementSubkind = self.getMovementSubkindFromCell(cell)
            self.createAlert(NSLocalizedString("expenseSubkind.delete", comment: "The delete expense subkind message"), message: String.localizedStringWithFormat(NSLocalizedString("expenseSubkind.delete.message", comment: "The delete expense subkind description"), movementSubkind.description), actionButtonMessage: NSLocalizedString("common.delete", comment: "The common message delete"), expenseKind: movementSubkind, operation: .DELETE_SUBKIND)
            
        }
        remove.backgroundColor = Diexpenses.redColor
        
        let edit = UITableViewRowAction(style: .Normal, title: NSLocalizedString("common.edit", comment: "The edit title")) {
            action, index in
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let movementSubkind = self.getMovementSubkindFromCell(cell)
            self.createAlert(NSLocalizedString("expenseSubkind.edit", comment: "The edit expense subkind message"), message: NSLocalizedString("expenseSubkind.edit.message", comment: "The edit expense subkind description"), actionButtonMessage: NSLocalizedString("common.update", comment: "The common message update"), expenseKind: movementSubkind, operation: .EDIT_SUBKIND)
        }
        edit.backgroundColor = Diexpenses.greenColor
        
        return [remove, edit]
    }
    
    func getMovementSubkindFromCell(cell: UITableViewCell) -> ExpenseKind {
        let id = cell.tag
        let description = cell.textLabel?.text
        return ExpenseKind(id: id, description: description!)
    }
}

// MARK: - UITableViewDataSource implementation for MovementKindsViewController
extension MovementSubkindsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expensesSubkinds.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Cell.BASIC_IDENTIFIER, forIndexPath: indexPath) as UITableViewCell
        let expenseSubkind = expensesSubkinds[indexPath.row]
        cell.tag = expenseSubkind.id.integerValue
        cell.textLabel?.text = expenseSubkind.description
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if expensesSubkinds.isEmpty {
            return NSLocalizedString("common.noData", comment: "The common no data message")
        }
        
        return nil
    }
    
}

// MARK: - API Request
extension MovementSubkindsViewController {
    
    // MARK: Load the movements subkinds calling to diexpensesAPI
    func loadMovementsSubkinds() {
        
        let url = String.localizedStringWithFormat(Constants.API.LIST_FIN_MOV_SUBTYPES, expenseKind.id)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            guard let _ =  data else {
                NSLog("Without Internet connection")
                return
            }
            
            do {
                let expensesSubkindsJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))  as? NSArray)!
                self.expensesSubkinds = ExpenseKind.modelsFromJSONArray(expensesSubkindsJson as! [JSON])!
                if !self.expensesSubkinds.isEmpty {
                    self.expensesSubkinds = self.expensesSubkinds.sort{$0.description < $1.description}
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.movementesSubkindsTableView.reloadData()
                })
                
            } catch let error as NSError {
                NSLog("Error getting expenses subkinds: \(error.localizedDescription)")
            }
        })
    }
    
    // MARK: Create a movement subkind calling to diexpensesAPI
    func createSubkind(value: String) {
        
        let url = String.localizedStringWithFormat(Constants.API.CREATE_FIN_MOV_SUBTYPES, expenseKind.id)
        let expenseSubkind = ExpenseKind(description: value)
        let expenseSubkindJson = JsonUtils.JSONStringify(expenseSubkind.toJSON()!, prettyPrinted: true)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.POST.rawValue, body: expenseSubkindJson, completionHandler: {
            data, response, error in
            
            self.loadSubkindsAfterOperation(data, expectedCode: 90)
        })
    }
    
    // MARK: Delete a movement subkind calling to diexpensesAPI
    func editSubkind(expenseSubkind: ExpenseKind) {
        
        let url = String.localizedStringWithFormat(Constants.API.UD_FIN_MOV_SUBTYPES, expenseKind.id, expenseSubkind.id)
        let expenseSubkindJson = JsonUtils.JSONStringify(expenseSubkind.toJSON()!, prettyPrinted: true)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.PUT.rawValue, body: expenseSubkindJson, completionHandler: {
            data, response, error in
            
            self.loadSubkindsAfterOperation(data, expectedCode: 99)
        })
    }
    
    // MARK: Edit a movement subkind calling to diexpensesAPI
    func deleteSubkind(subkindId: NSNumber) {
        
        let url = String.localizedStringWithFormat(Constants.API.UD_FIN_MOV_SUBTYPES, expenseKind.id, subkindId)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.DELETE.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            self.loadSubkindsAfterOperation(data, expectedCode: 104)
        })
    }
    
    // MARK: Generic operation called after create, delete and edit movement subkind
    func loadSubkindsAfterOperation(data: NSData?, expectedCode: Int) {
        if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: expectedCode) {
            self.loadMovementsSubkinds()
        }
    }

}


