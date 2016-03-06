//
//  MovementKindsViewController.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 5/3/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit
import Gloss

class MovementKindsViewController: UIViewController {

    var expensesKinds : [ExpenseKind] = []

    @IBOutlet weak var movementsKindsTableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshMovementsKinds:", forControlEvents: .ValueChanged)
        
        return refreshControl
    }()
    
    @IBAction func onNewMovementKind(sender: UIBarButtonItem) {
        createAlert(NSLocalizedString("expenseKind.new", comment: "The new expense kind message"), message: NSLocalizedString("expenseKind.new.message", comment: "The new expense kind description"), actionButtonMessage: NSLocalizedString("common.save", comment: "The common message save"), expenseKind: nil, operation: .NEW_KIND)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        movementsKindsTableView.addSubview(self.refreshControl)
        
        self.loadMovementsKinds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension MovementKindsViewController {
    
    func refreshMovementsKinds(refreshControl: UIRefreshControl) {
        loadMovementsKinds()
        refreshControl.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Constants.Segue.TO_EXPENSES_SUBKINDS_VC {
                if let movementsSubkindsViewController = segue.destinationViewController as? MovementSubkindsViewController {
                    let basicCell = sender as? UITableViewCell
                    if let cell = basicCell {
                        movementsSubkindsViewController.expenseKind = ExpenseKind(id: cell.tag, description: (cell.textLabel?.text)!)
                    }
                }
            }
        }
    }
}

extension MovementKindsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let remove = UITableViewRowAction(style: .Destructive, title: NSLocalizedString("common.delete", comment: "The delete title")) {
            action, index in
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let id = cell.tag
            let description = cell.textLabel?.text
            let movementKind = ExpenseKind(id: id, description: description!)
            
            self.createAlert(NSLocalizedString("expenseKind.delete", comment: "The delete expense kind message"), message: String.localizedStringWithFormat(NSLocalizedString("expenseKind.delete.message", comment: "The delete expense kind description"), movementKind.description), actionButtonMessage: NSLocalizedString("common.delete", comment: "The common message delete"), expenseKind: movementKind, operation: .DELETE_KIND)
            
        }
        remove.backgroundColor = Diexpenses.redColor
        
        let edit = UITableViewRowAction(style: .Normal, title: NSLocalizedString("common.edit", comment: "The edit title")) {
            action, index in
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let id = cell.tag
            let description = cell.textLabel?.text
            let movementKind = ExpenseKind(id: id, description: description!)
            self.createAlert(NSLocalizedString("expenseKind.edit", comment: "The edit expense kind message"), message: NSLocalizedString("expenseKind.edit.message", comment: "The edit expense kind description"), actionButtonMessage: NSLocalizedString("common.update", comment: "The common message update"), expenseKind: movementKind, operation: .EDIT_KIND)
        }
        edit.backgroundColor = Diexpenses.greenColor
        
        return [remove, edit]
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(Constants.Segue.TO_EXPENSES_SUBKINDS_VC, sender: tableView.cellForRowAtIndexPath(indexPath)!)
    }
}

extension MovementKindsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expensesKinds.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Cell.BASIC_IDENTIFIER, forIndexPath: indexPath) as UITableViewCell
        let expenseKind = expensesKinds[indexPath.row]
        cell.tag = expenseKind.id.integerValue
        cell.textLabel?.text = expenseKind.description
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if expensesKinds.isEmpty {
            return NSLocalizedString("common.noData", comment: "The common no data message")
        }
        
        return nil
    }
    
}

extension MovementKindsViewController {

    func createAlert(title: String, message: String, actionButtonMessage: String, var expenseKind: ExpenseKind?, operation: KindsOperations) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        var style: UIAlertActionStyle = .Destructive
        if operation != .DELETE_KIND {
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.text = expenseKind?.description
            })
            style = .Default
        }
        
        alert.addAction(UIAlertAction(title: actionButtonMessage, style: style, handler: {
            (action) -> Void in
            if operation == .DELETE_KIND {
                self.removeMovementKind((expenseKind?.id)!)
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
            
            if operation == .NEW_KIND {
                self.createKind(textField.text!)
                return
            }
            if operation == .EDIT_KIND {
                expenseKind?.description = textField.text!
                self.editMovementKind(expenseKind!)
                return
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.cancel", comment: "The common cancel message"), style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension MovementKindsViewController {
    
    func loadMovementsKinds() {
        
        let url = String.localizedStringWithFormat(Constants.API.LIST_FIN_MOV_TYPES, Diexpenses.user.id)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            guard let _ =  data else {
                NSLog("Without Internet connection")
                return
            }
            
            do {
                let expensesKindsJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))  as? NSArray)!
                self.expensesKinds = ExpenseKind.modelsFromJSONArray(expensesKindsJson as! [JSON])!
                if !self.expensesKinds.isEmpty {
                    self.expensesKinds = self.expensesKinds.sort{$0.description < $1.description}
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.movementsKindsTableView.reloadData()
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
            
            self.loadMovementsAfterOperation(data, expectedCode: 60)
        })
    }

    func removeMovementKind(id: NSNumber) {
        let url = String.localizedStringWithFormat(Constants.API.UD_FIN_MOV_TYPES, Diexpenses.user.id, id)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.DELETE.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            self.loadMovementsAfterOperation(data, expectedCode: 71)
        })
    }
    
    func editMovementKind(expenseKind: ExpenseKind) {
        let url = String.localizedStringWithFormat(Constants.API.UD_FIN_MOV_TYPES, Diexpenses.user.id, expenseKind.id)
        let expenseKindJson = JsonUtils.JSONStringify(expenseKind.toJSON()!, prettyPrinted: true)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.PUT.rawValue, body: expenseKindJson, completionHandler: {
            data, response, error in
            
            self.loadMovementsAfterOperation(data, expectedCode: 66)
        })
    }
    
    func loadMovementsAfterOperation(data: NSData?, expectedCode: Int) {
        if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: expectedCode) {
            self.loadMovementsKinds()
        }
    }
    
}

