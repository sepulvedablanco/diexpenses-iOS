//
//  StatisticsViewController.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 14/5/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit
import Charts
import Gloss

class StatisticsViewController: UIViewController {
    
    static let allYears = NSLocalizedString("statistics.historical", comment: "The historical message")
    static let allMonths = NSLocalizedString("statistics.allMonths", comment: "The all months message")
    static let allKinds = NSLocalizedString("statistics.allKinds", comment: "The all kinds message")
    static let selectKindFirst = NSLocalizedString("statistics.kindFirst", comment: "The select kind first message")
    static let allSubkinds = NSLocalizedString("statistics.allSubkinds", comment: "The all subkinds message")
    static let allBankAccounts = NSLocalizedString("statistics.allBankAccounts", comment: "The all bank accounts message")

    var incomes : Double = 0.0
    var expenses : Double = 0.0

    var years: [String] = []
    var months = Diexpenses.getMonths(false)
    var expensesKinds : [ExpenseKind] = [ExpenseKind(description: allKinds)]
    var expensesSubKinds : [ExpenseKind] = [ExpenseKind(description: selectKindFirst)]
    var bankAccounts : [BankAccount] = [BankAccount(description: allBankAccounts)]

    var selectedYear: Int!
    var selectedMonth: Int!
    var selectedKind: ExpenseKind!
    var selectedSubkind: ExpenseKind!
    var selectedBankAccount: BankAccount!

    var loadingMask: LoadingMask!
    var loadingLock: Bool = true

    @IBOutlet weak var yearTextField: UITextField!
    var yearCustomPicker: CustomPicker!

    @IBOutlet weak var monthTextField: UITextField!
    var monthCustomPicker: CustomPicker!

    @IBOutlet weak var kindTextField: UITextField!
    var kindsCustomPicker: CustomPicker!

    @IBOutlet weak var subkindTextField: UITextField!
    var subkindsCustomPicker: CustomPicker!

    @IBOutlet weak var bankAccountTextField: UITextField!
    var bankAccountsCustomPicker: CustomPicker!

    @IBOutlet weak var pieChart: PieChartView!
    
    @IBAction func onSeeStatistics(sender: UIButton) {
        getStatistics()
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

// MARK: - Methods called when data is not loaded
extension StatisticsViewController {
    
    // MARK: Initialize the View Controller
    func initVC() {
        loadingMask = LoadingMask(view: view)
        loadingMask.showMask()
        initChart()
        initData()
        configureCustomPickers()
        loadExpensesKinds()
        loadBankAccounts()
    }
        
    // MARK: Configuration of the chart
    func initChart() {
        self.pieChart.noDataText = ""
        self.pieChart.noDataTextDescription = ""
        self.pieChart.legend.enabled = false // Hides the leyend
        self.pieChart.descriptionText = "" // Hides the desciption down-right the chart
    }
    
    func initData() {
        let intYears = Diexpenses.getYears()
        years = intYears.map {
            String($0)
        }
        
        years.insert(StatisticsViewController.allYears, atIndex: 0)
        months = months.reverse()
        months.insert(StatisticsViewController.allMonths, atIndex: 0)
    }
    
}

// MARK: - Custom pickers operations
extension StatisticsViewController {
    
    // MARK: Configure custom pickers
    func configureCustomPickers() {
        
        yearCustomPicker = CustomPicker(target: self, uiTextField: yearTextField, items: getBarItems(#selector(StatisticsViewController.onYearSelected), cancelSelector: #selector(StatisticsViewController.onCancelYear)))
        yearCustomPicker.picker.delegate = self
        yearCustomPicker.picker.dataSource = self
        yearTextField.text = years[0]

        monthCustomPicker = CustomPicker(target: self, uiTextField: monthTextField, items: getBarItems(#selector(StatisticsViewController.onMonthSelected), cancelSelector: #selector(StatisticsViewController.onCancelMonth)))
        monthCustomPicker.picker.delegate = self
        monthCustomPicker.picker.dataSource = self
        monthTextField.text = months[0]

        kindsCustomPicker = CustomPicker(target: self, uiTextField: kindTextField, items: getBarItems(#selector(StatisticsViewController.onKindSelected), cancelSelector: #selector(StatisticsViewController.onCancelKind)))
        kindsCustomPicker.picker.delegate = self
        kindsCustomPicker.picker.dataSource = self
        kindTextField.text = StatisticsViewController.allKinds
        
        subkindsCustomPicker = CustomPicker(target: self, uiTextField: subkindTextField, items: getBarItems(#selector(StatisticsViewController.onSubkindSelected), cancelSelector: #selector(StatisticsViewController.onCancelSubkind)))
        subkindsCustomPicker.picker.delegate = self
        subkindsCustomPicker.picker.dataSource = self
        subkindTextField.enabled = false
        subkindTextField.text = StatisticsViewController.selectKindFirst
        
        bankAccountsCustomPicker = CustomPicker(target: self, uiTextField: bankAccountTextField, items: getBarItems(#selector(StatisticsViewController.onBankAccountSelected), cancelSelector: #selector(StatisticsViewController.onCancelBankAccount)))
        bankAccountsCustomPicker.picker.delegate = self
        bankAccountsCustomPicker.picker.dataSource = self
        bankAccountTextField.text = StatisticsViewController.allBankAccounts

    }
    
    // MARK: This method create the UIBarButtonItem wich are contained inside the custom pickers
    func getBarItems(doneSelector: Selector, cancelSelector: Selector) -> [UIBarButtonItem] {
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("common.cancel", comment: "The common cancel message"), style: .Plain, target: self, action: cancelSelector)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("common.done", comment: "The common done message"), style: .Plain, target: self, action: doneSelector)
        return [cancelButton, spaceButton, doneButton]
    }
    
    // MARK: This method is called when some year of custom picker is selected
    func onYearSelected() {
        let strYear = years[yearCustomPicker.picker.selectedRowInComponent(0)]
        selectedYear = Int(strYear)
        yearCustomPicker.doCommonOperations(strYear)
    }
    
    // MARK: This method is called when cancel button of year custom picker is selected
    func onCancelYear() {
        if let year = selectedYear {
            yearCustomPicker.doCommonOperations(String(year))
        } else {
            yearCustomPicker.doCommonOperations(StatisticsViewController.allYears)
        }
    }

    // MARK: This method is called when some month of custom picker is selected
    func onMonthSelected() {
        let indexSelecteed = monthCustomPicker.picker.selectedRowInComponent(0)
        if indexSelecteed == 0 {
            selectedMonth = nil
        } else {
            selectedMonth = indexSelecteed
        }
        monthCustomPicker.doCommonOperations(months[indexSelecteed])
    }

    // MARK: This method is called when cancel button of month custom picker is selected
    func onCancelMonth() {
        if let month = selectedMonth {
            monthCustomPicker.doCommonOperations(months[month])
        } else {
            monthCustomPicker.doCommonOperations(StatisticsViewController.allMonths)
        }
    }
    
    // MARK: This method is called when some kind of custom picker is selected
    func onKindSelected() {
        let tempKind = expensesKinds[kindsCustomPicker.picker.selectedRowInComponent(0)]
        if let _ = tempKind.id {
            selectedKind = tempKind
            kindsCustomPicker.doCommonOperations(tempKind.description)
            subkindsCustomPicker.doCommonOperations(StatisticsViewController.allSubkinds)
            subkindTextField.enabled = true
        } else {
            selectedKind = nil
            selectedSubkind = nil
            kindsCustomPicker.doCommonOperations(StatisticsViewController.allKinds)
            subkindsCustomPicker.doCommonOperations(StatisticsViewController.selectKindFirst)
            subkindTextField.enabled = false
        }
    }
    
    // MARK: This method is called when cancel button of kind custom picker is selected
    func onCancelKind() {
        if let kind = selectedKind {
            kindsCustomPicker.doCommonOperations(kind.description)
        } else {
            kindsCustomPicker.doCommonOperations(StatisticsViewController.allKinds)
        }
    }
    
    // MARK: This method is called when some subkind of custom picker is selected
    func onSubkindSelected() {
        let tempSubkind = expensesSubKinds[subkindsCustomPicker.picker.selectedRowInComponent(0)]
        if let _ = tempSubkind.id {
            selectedSubkind = tempSubkind
            subkindsCustomPicker.doCommonOperations(tempSubkind.description)
        } else {
            selectedSubkind = nil
            subkindsCustomPicker.doCommonOperations(StatisticsViewController.allSubkinds)
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
            subkindsCustomPicker.doCommonOperations(StatisticsViewController.allSubkinds)
        } else {
            subkindsCustomPicker.doCommonOperations(StatisticsViewController.selectKindFirst)
        }
        
    }
    
    // MARK: This method is called when some bank account of custom picker is selected
    func onBankAccountSelected() {
        let tempBankAccount = bankAccounts[bankAccountsCustomPicker.picker.selectedRowInComponent(0)]
        if let _ = tempBankAccount.id {
            selectedBankAccount = tempBankAccount
            bankAccountsCustomPicker.doCommonOperations(tempBankAccount.description)
        } else {
            selectedBankAccount = nil
            bankAccountsCustomPicker.doCommonOperations(StatisticsViewController.allBankAccounts)
        }
    }
    
    // MARK: This method is called when cancel button of bank accounts custom picker is selected
    func onCancelBankAccount() {
        if let bankAccount = selectedBankAccount {
            bankAccountsCustomPicker.doCommonOperations(bankAccount.description)
        } else {
            bankAccountsCustomPicker.doCommonOperations(StatisticsViewController.allBankAccounts)
        }
    }
}

// MARK: - UIPickerViewDelegate implementation for StatisticsViewController
extension StatisticsViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == yearCustomPicker.picker {
            return self.years[row]
        }
        if pickerView == monthCustomPicker.picker {
            return self.months[row]
        }
        if pickerView == kindsCustomPicker.picker {
            return self.expensesKinds[row].description
        }
        if pickerView == subkindsCustomPicker.picker {
            return self.expensesSubKinds[row].description
        }
        if pickerView == bankAccountsCustomPicker.picker {
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

// MARK: - UIPickerViewDataSource implementation for StatisticsViewController
extension StatisticsViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == yearCustomPicker.picker {
            return self.years.count
        }
        if pickerView == monthCustomPicker.picker {
            return self.months.count
        }
        if pickerView == kindsCustomPicker.picker {
            return self.expensesKinds.count
        }
        if pickerView == subkindsCustomPicker.picker {
            return self.expensesSubKinds.count
        }
        if pickerView == bankAccountsCustomPicker.picker {
            return self.bankAccounts.count
        }
        return 0
    }
}

// MARK: - API Request
extension StatisticsViewController {
    
    func checkLoadingLock() {
        if loadingLock {
            loadingLock = false
        } else {
            loadingMask.hideMask()
        }
    }
    
    // MARK: Load the expenses kinds calling to diexpensesAPI
    func loadExpensesKinds() {
        
        let url = String.localizedStringWithFormat(Constants.API.LIST_FIN_MOV_TYPES, Diexpenses.user.id)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d =  data {
                do {
                    self.checkLoadingLock()
                    let expensesKindsJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions(rawValue: 0))  as? NSArray)!
                    let newExpensesKinds = ExpenseKind.modelsFromJSONArray(expensesKindsJson as! [JSON])!
                    let allKinds = ExpenseKind(description: StatisticsViewController.allKinds)
                    if newExpensesKinds.isEmpty {
                        self.expensesKinds = [allKinds]
                    } else {
                        self.expensesKinds = newExpensesKinds
                        self.expensesKinds.insert(allKinds, atIndex: 0)
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
                    let allSubkinds = ExpenseKind(description: StatisticsViewController.allSubkinds)
                    if newExpensesSubkinds.isEmpty {
                        self.expensesSubKinds = [allSubkinds]
                    } else {
                        self.expensesSubKinds = newExpensesSubkinds
                        self.expensesSubKinds.insert(allSubkinds, atIndex: 0)
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
                    self.checkLoadingLock()
                    let bankAccountsJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions(rawValue: 0))  as? NSArray)!
                    
                    let lstBankAccounts = BankAccount.modelsFromJSONArray(bankAccountsJson as! [JSON])!
                    let allBankAccounts = BankAccount(description: StatisticsViewController.allBankAccounts)
                    if lstBankAccounts.isEmpty {
                        self.bankAccounts = [allBankAccounts]
                    }else {
                        self.bankAccounts = lstBankAccounts
                        self.bankAccounts.insert(allBankAccounts, atIndex: 0)
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
    
    // MARK: Triggers the logic of getting statistics.
    func getStatistics() {
        loadingMask.showMask()
        loadingLock = true
        
        incomes = 0
        expenses = 0
        
        loadExpenses()
        loadIncomes()
    }
    
    // MARK: Utility to get statistics URL query.
    func getAmountURL(id: String, isExpense: Bool, month: Int!, year: Int!, kindId: NSNumber!, subkindId: NSNumber!, bankAccountId: NSNumber!) -> String {
        var url = String.localizedStringWithFormat(Constants.API.STATISTICS_URL, id, isExpense.description)
        if let y = year {
            url += "&y=" + String(y)
        }
        if let m = month {
            url += "&m=" + String(m)
        }
        if let k = selectedKind {
            if let id = k.id {
                url += "&t=" + String(id)
            }
        }
        if let s = selectedSubkind {
            if let id = s.id {
                url += "&s=" + String(id)
            }
        }
        if let b = selectedBankAccount {
            if let id = b.id {
                url += "&b=" + String(id)
            }
        }
        return url
    }

    // MARK: Load statistics expenses calling to diexpensesAPI
    func loadExpenses() {
        
        let url = getAmountURL(String(Diexpenses.user.id), isExpense: true, month: selectedMonth, year: selectedYear, kindId: selectedKind?.id, subkindId: selectedSubkind?.id, bankAccountId: selectedBankAccount?.id)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d = data {
                let stringExpenses = NSString(data: d, encoding: NSUTF8StringEncoding) as! String
                self.expenses = Diexpenses.formatDecimalValue(string: stringExpenses).doubleValue
                
                self.checkDrawChart()
                
                self.checkLoadingLock()
            }
        })
    }
    
    // MARK: Load statistics incomes calling to diexpensesAPI
    func loadIncomes() {
        
        let url = getAmountURL(String(Diexpenses.user.id), isExpense: false, month: selectedMonth, year: selectedYear, kindId: selectedKind?.id, subkindId: selectedSubkind?.id, bankAccountId: selectedBankAccount?.id)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d = data {
                let stringIncomes = NSString(data: d, encoding: NSUTF8StringEncoding) as! String
                self.incomes = Diexpenses.formatDecimalValue(string: stringIncomes).doubleValue

                self.checkDrawChart()
                
                self.checkLoadingLock()
            }
        })
    }

}

// MARK: - Methods called when data is loading/loaded
extension StatisticsViewController {
    
    // MARK: Is called when expenses or incomes request finished.
    func checkDrawChart() {
        if !loadingLock {
            drawChart()
        }
    }
    
    // MARK: Is called when incomes and expenses are loaded. If there are incomes or expenses the chart is drawed
    func drawChart() {
        if incomes == 0 && expenses == 0 {
            NSLog("Without data")
            self.pieChart.noDataText = NSLocalizedString("common.noData", comment: "The common no data message")
            dispatch_async(dispatch_get_main_queue(), {
                self.pieChart.data = nil
            })
            return
        }
        
        let dataPoints = [NSLocalizedString("common.incomes", comment: "The incomes"),
                          NSLocalizedString("common.expenses", comment: "The expenses")]
        
        let values = [incomes, expenses]
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.pieChart.data = pieChartData
            self.pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInQuint)
        })
        
        let colors: [UIColor] = [Diexpenses.greenColor, Diexpenses.redColor]
        pieChartDataSet.colors = colors
    }
}
