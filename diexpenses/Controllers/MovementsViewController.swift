//
//  NewMovementViewController.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 6/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit
import Gloss

class MovementsViewController: UIViewController {

    @IBOutlet weak var datePickerView: UIPickerView!
    @IBOutlet weak var movementsTableView: UITableView!

    var movements : [Movement] = []
    var months: [String] = []
    let years: [Int] = {
        let todayDate = NSDate()
        let todayCalendar = NSCalendar.currentCalendar()
        let components = todayCalendar.components([.Year], fromDate: todayDate)
        var years = [Int]()
        for var index = components.year; index >= 2010; --index {
            years.append(index)
        }
        return years
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshMovements:", forControlEvents: .ValueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        movementsTableView.addSubview(self.refreshControl)
        
        loadMonths()
        loadMovements()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MovementsViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String(years[row])
        case 1:
            return months[row]
        default:
            return nil
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let todayDate = NSDate()
            let todayCalendar = NSCalendar.currentCalendar()
            let components = todayCalendar.components([.Year], fromDate: todayDate)
            let reload = loadMonths(years[row] == components.year)
            if reload {
                pickerView.reloadComponent(1)
            }
            pickerView.selectRow(0, inComponent: 1, animated: true)
        }
        
        loadMovements()
    }

}

extension MovementsViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return years.count
        case 1:
            return months.count
        default:
            return 0
        }

    }
}

extension MovementsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movements.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Cell.MOVEMENT_IDENTIFIER, forIndexPath: indexPath) as UITableViewCell
        
        let movementCell = cell as! MovementCell
        let movement = movements[indexPath.row]
        movementCell.movement = movement
        movementCell.expenseIncomeImageView.image = UIImage(named: getMovementImage(movement.expense))
        movementCell.descriptionAmountLabel.text = movement.concept + " (" + Diexpenses.formatCurrency(movement.amount) + ")"
        var subkind = ""
        if let fmSubkind = movement.financialMovementSubtype {
            subkind = " - " + fmSubkind.description
        }
        movementCell.kindSubkindLabel.text = movement.financialMovementType.description + subkind
        movementCell.bankAccountLabel.text = movement.bankAccount.description //+ " (" + movement.bankAccount.completeBankAccount + ")"
        movementCell.transactionDateLabel.text = Diexpenses.formatDate(movement.transactionDate, format: Diexpenses.DAY_MONTH_YEAR)
        return movementCell
    }
    
    // Swipe
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        let remove = UITableViewRowAction(style: .Destructive, title: NSLocalizedString("common.delete", comment: "The delete title")) {
            action, index in
            
            let cell = self.movementsTableView.cellForRowAtIndexPath(indexPath)!
            let movementCell = cell as! MovementCell
            self.removeMovement(movementCell.movement)
        }
        remove.backgroundColor = Diexpenses.redColor
        return [remove]
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    //end swipe
}

extension MovementsViewController {
    
    func refreshMovements(refreshControl: UIRefreshControl) {
        loadMovements()
        refreshControl.endRefreshing()
    }
    
    func getMovementImage(isExpense: Bool) -> String {
        if isExpense {
            return Constants.Images.MINUS
        } else {
            return Constants.Images.PLUS
        }
    }
}

extension MovementsViewController {
    
    func loadMonths(isThisYear: Bool = true) -> Bool {
        if !isThisYear && months.count == 12 {
            return false
        }
        
        var initialMonthIndex = 12
        if isThisYear {
            let todayDate = NSDate()
            let todayCalendar = NSCalendar.currentCalendar()
            let components = todayCalendar.components([.Month], fromDate: todayDate)
            initialMonthIndex = components.month
        }
        
        let dateFormatter = NSDateFormatter()
        let monthSymbols = dateFormatter.standaloneMonthSymbols
        
        months = [String]()
        for var index = initialMonthIndex; index > 0; --index {
            months.append(monthSymbols[index - 1])
        }
        
        return true
    }
}

extension MovementsViewController {
    
    func loadMovements() {
        
        let year = String(years[datePickerView.selectedRowInComponent(0)])
        let month = String(months.count - datePickerView.selectedRowInComponent(1))
        let url = String.localizedStringWithFormat(Constants.API.LIST_MOV_BY_MONTH, Diexpenses.user.id, year, month)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d = data {
                do {
                    let movementsPageJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions(rawValue: 0))  as? NSDictionary)!
                    let movementsPage = MovementPage(json: movementsPageJson as! JSON)
                    self.movements = movementsPage!.page
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.movementsTableView.reloadData()
                    })
                } catch let error as NSError {
                    NSLog("An error has occurred: \(error.localizedDescription)")
                }
            } else {
                NSLog("Without Internet connection")
            }
        })
    }
    
    func removeMovement(movement: Movement) {
        
        let movementsURL = String.localizedStringWithFormat(Constants.API.UD_MOVEMENT_URL, Diexpenses.user.id, movement.id)
        Diexpenses.doRequest(movementsURL, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.DELETE.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: 133) {
                Notificator.fireNotification(expense: movement.expense)
                self.loadMovements()
            }
        })
    }    

}