//
//  HomeViewController.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 25/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit
import Charts
import Gloss

class HomeViewController: UIViewController {

    let loadingMask = LoadingMask()
    
    let date = NSDate()
    let calendar = NSCalendar.currentCalendar()

    var incomes : Double = 0.0
    var expenses : Double = 0.0
    var incomesLoad = false
    var expensesLoad = false

    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var monthIncomeLabel: UILabel!
    @IBOutlet weak var monthExpensesLabel: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBAction func onLogOut() {
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        self.performSegueWithIdentifier(Constants.Segue.TO_LOGIN_VC, sender: self)
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
extension HomeViewController {
    
    // MARK: Initialize the View Controller
    func initVC() {
        registerNotifications()
        initChart()
        loadingMask.showMask(view)
        loadIncomes()
        loadExpenses()
        loadTotalAmount()
        setGreetings()
    }
    
    // MARK: Register of notifications fired when a bank account is created, updated or delete and when a movement is crearted or deleted
    func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadTotalAmount", name:Constants.Notifications.BANK_ACCOUNTS_CHANGED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadExpenses", name:Constants.Notifications.EXPENSES_CHANGED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadIncomes", name:Constants.Notifications.INCOMES_CHANGED, object: nil)
    }
    
    // MARK: Configuration of the chart
    func initChart() {
        self.pieChart.noDataText = NSLocalizedString("home.chart.nodata", comment: "There is not data for chart")
        self.pieChart.noDataTextDescription = NSLocalizedString("home.chart.nodata.description", comment: "There is not data for chart description")
        self.pieChart.legend.enabled = false // Hides the leyend
        self.pieChart.descriptionText = "" // Hides the desciption down-right the chart
    }

    // MARK: Show the greeting
    func setGreetings() {
        let localizedGreeting = NSLocalizedString("home.greetings", comment: "The greetings")
        dispatch_async(dispatch_get_main_queue(), {
            self.greetingLabel.text = String.localizedStringWithFormat(localizedGreeting, Diexpenses.user.name)
        })
    }
    
}

// MARK: - Methods called when data is loading/loaded
extension HomeViewController {
    
    // MARK: Is called when expenses or incomes request finished. If data is loaded hide the mask, draws chart and set balance message
    func checkDrawChart(isDataLoaded: Bool) {
        if isDataLoaded {
            loadingMask.hideMask()
            drawChart()
            doBalance()
        }
    }

    // MARK: Is called when incomes and expenses are loaded. If there are incomes or expenses the chart is drawed
    func drawChart() {
        if incomes == 0 && expenses == 0 {
            NSLog("Without data")
            return
        }
        
        let dataPoints = [NSLocalizedString("home.incomes", comment: "The incomes"),
            NSLocalizedString("home.expenses", comment: "The expenses")]
        
        let values = [incomes, expenses]

        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        //pieChartData.setValueTextColor(UIColor.blackColor())
        
        dispatch_async(dispatch_get_main_queue(), {
            self.pieChart.data = pieChartData
            self.pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInQuint)
        })
        
        let colors: [UIColor] = [Diexpenses.greenColor, Diexpenses.redColor]
        pieChartDataSet.colors = colors
    }
    
    // MARK: Is called when incomes and expenses are loaded. If there are incomes or expenses the balance message is showed
    func doBalance() {
        if incomes == 0 && expenses == 0 {
            return
        }

        dispatch_async(dispatch_get_main_queue(), {
            if self.incomes > self.expenses {
                self.balanceLabel.text = NSLocalizedString("home.balance.high", comment: "The high balance")
            } else if self.incomes == self.expenses {
                self.balanceLabel.text = NSLocalizedString("home.balance.medium", comment: "The medium balance")
            } else {
                self.balanceLabel.text = NSLocalizedString("home.balance.low", comment: "The log balance")
            }
        })
    }
}

// MARK: - API Request
extension HomeViewController {
    
    // MARK: Utility to parameterice expenses and incomes request URL.
    func getAmountURL(id: String, isExpense: Bool, month: String, year: String) -> String {
        return String.localizedStringWithFormat(Constants.API.AMOUNTS_URL, id, isExpense.description, month, year)
    }

    // MARK: Load current month expenses calling to diexpensesAPI
    func loadExpenses() {
        let components = calendar.components([.Month , .Year], fromDate: date)
        
        let url = getAmountURL(String(Diexpenses.user.id), isExpense: true, month: String(components.month), year: String(components.year))
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d = data {
                let stringExpenses = NSString(data: d, encoding: NSUTF8StringEncoding) as! String
                self.expenses = Diexpenses.formatDecimalValue(string: stringExpenses).doubleValue
                let localizedExpenses = NSLocalizedString("home.totalExpenses", comment: "The total expenses")
                dispatch_async(dispatch_get_main_queue(), {
                    self.monthExpensesLabel.text = String.localizedStringWithFormat(localizedExpenses, Diexpenses.formatCurrency(self.expenses))
                })
                
                self.expensesLoad = true
                self.checkDrawChart(self.incomesLoad)
            } else {
                NSLog("Without Internet connection")
            }
        })
    }
    
    // MARK: Load current month incomes calling to diexpensesAPI
    func loadIncomes() {
        
        let components = calendar.components([.Month , .Year], fromDate: date)
        let url = getAmountURL(String(Diexpenses.user.id), isExpense: false, month: String(components.month), year: String(components.year))
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d = data {
                let stringIncomes = NSString(data: d, encoding: NSUTF8StringEncoding) as! String
                self.incomes = Diexpenses.formatDecimalValue(string: stringIncomes).doubleValue
                let localizedIncomes = NSLocalizedString("home.totalIncomes", comment: "The total incomes")
                dispatch_async(dispatch_get_main_queue(), {
                    self.monthIncomeLabel.text = String.localizedStringWithFormat(localizedIncomes, Diexpenses.formatCurrency(self.incomes))
                })
                
                self.incomesLoad = true
                self.checkDrawChart(self.expensesLoad)
            } else {
                NSLog("Without Internet connection")
            }
        })
    }
    
    // MARK: Load user total amount calling to diexpensesAPI
    func loadTotalAmount() {
        
        let url = String.localizedStringWithFormat(Constants.API.TOTAL_AMOUNT_URL, Diexpenses.user.id)
        Diexpenses.doRequest(url, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d = data {
                let stringTotalAmount = NSString(data: d, encoding: NSUTF8StringEncoding) as! String
                let numericTotalAmount = Diexpenses.formatDecimalValue(string: stringTotalAmount)
                let localizedTotalAmount = NSLocalizedString("home.totalAmount", comment: "The total amount")
                dispatch_async(dispatch_get_main_queue(), {
                    self.totalAmountLabel.text = String.localizedStringWithFormat(localizedTotalAmount, Diexpenses.formatCurrency(numericTotalAmount))
                })
            } else {
                NSLog("Without Internet connection")
            }
        })
    }
}
