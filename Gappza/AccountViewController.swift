//
//  AccountViewController.swift
//  Gappza
//
//  Created by Firdavsii Majidzoda on 11/8/16.
//  Copyright © 2016 Gappza. All rights reserved.
//

import UIKit

class AccountViewController:UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Outlets
    @IBOutlet var welcomeTextLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    
    // Fields
    private var transactionStore  = TransactionStore()
    private let textCellIdentifier = "TransactionCell"
    
    private var currentUser: User!

    private var logOutMessage: String!
    private var logOutTimeSet: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    // MARK: Prepare For View
    /**
     Prepares and configures subviews.
     */
    private func prepareView() {
        // Initialization
        currentUser = User()
        logOutMessage = ""
        
        // API call to get user's first name for greeting
        getUsersFirstName()
        
        // Transaction TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // API Call to get existing transactions for current user
        loadTransactions()
        
        // Log out cinfig
        setObserversForTimeSet()
    }
    
    /**
        Add observers for UIApplicationDidEnterBackground and UIApplicationWillEnterForeground for timeSet with following selectors:
         - enterBackground()
         - enterForeground()
     */
    private func setObserversForTimeSet(){
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    
    /**
        Sets current time when enter background as initial of inactivity
     */
    func enterBackground(){
        logOutTimeSet = Date()
    }
    
    /**
        Checks logOutTimeSet if greater than 15 mins, log out, segue to LogInVC with message
     */
    func enterForeground(){
        if logOutTimeSet.timeIntervalSinceNow <= -15*60 {
            logOutMessage = "We logged you out for security purposes."
            performSegue(withIdentifier: "fromAccountVCtoLogInVC", sender: self)
        }
    }
    
    
    // MARK: Transaction TableView
    // MARK: API Calls
    /**
        Load transaction from Data Base for current user, and call createTransactions()
     */
    private func loadTransactions() {
        transactionStore.getTransactions(currentUser.loadCurrentUserEmail()){
            response in
            // Getting response status
            guard let status = response["status"] as? String else {
                // Can't get status
                self.alertToUserWithMesage("Unexpected error occured, please try again later", segueIdentifier: "fromAccountVCtoLogInVC")
                return
            }
            
            switch status{
            case "1":
                // Success, getting transaction array
                guard let transactionsArray = response["transactionsArray"] as? [[String: AnyObject]] else {
                    // Can't get transaction array
                    self.alertToUserWithMesage("Unexpected error occured, please try again later.", segueIdentifier: "fromAccountVCtoLogInVC")
                    return
                }
                self.createTransactions(transactionsArray)
                
            case "-1":
                self.alertToUserWithMesage("Unexpected error occured, please try again later.", segueIdentifier: "fromAccountVCtoLogInVC")
                
            default: break
            }
        }
    }
    
    /**
        Fetch transactions from JSON result and do followings:
         - Create transaction
         - Add transaction to transacionStore
         - Set transaction to Transactions TableView
        - parameter transactionsArray: JSON to be fetched
     */
    private func createTransactions(_ transactionsArray: [[String: AnyObject]]){
        for transacion in transactionsArray{
            // Create a new Item and add it to the store
            guard let number = transacion["phoneNumber"] as? String,
                let amount = transacion["amount"] as? String,
                let date = transacion["date"] as? String,
                let status = transacion["status"] as? String else {
                    // Can't get transaction
                    return
            }
            
            let newTransaction = transactionStore.createTransaction(number: number, date: date, amount: amount, status: status)
            
            
            // Figure out where that item is in the array
            if let index = transactionStore.allTransactions.index(of: newTransaction) {
                let indexPath = IndexPath(row: index, section: 0)
                
                // Insert this new row into the table.
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionStore.allTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create an instance of UITableViewCell, with default appearance
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell",
                                                 for: indexPath) as! TransactionCell
        let transaction = transactionStore.allTransactions[indexPath.row]
        
        
        
        cell.number.text = transaction.number
        cell.amount.text = transaction.amount
        cell.date.text = transaction.date
        cell.status.text = transaction.status
        return cell
    }
    
    /**
        Get user's first name.
         - Set welcomeTextLabel text to loaded first name
         - Save the loaded first name
     */
    private func getUsersFirstName() {
        GapzaAPI.getUsersFirstName(["email":currentUser.loadCurrentUserEmail()]){
            (response) -> Void in
            
            // Getting reponse status
            guard let status = response["status"] else {
                // Can't get a response status
                self.alertToUserWithMesage("Unexpected error occured, please try again later.", segueIdentifier: "fromAccountVCtoLogInVC")
                return
            }
            
            switch status {
                
            case "1":
                // Success, getting first name
                guard let firstName = response["message"] else {
                    // Can't get first name
                    self.alertToUserWithMesage("Unexpected error occured, please try again later.", segueIdentifier: "fromAccountVCtoLogInVC")
                    return
                }
                self.welcomeTextLabel.text = firstName
                self.currentUser.saveFirstNameForCurrentUser(firstName: firstName)
                
            case "-1":
                // Failure, getting error message
                self.alertToUserWithMesage("Unexpected error occured, please try again later.", segueIdentifier: "fromAccountVCtoLogInVC")
                
            default:
                break
            }
            
        }
    }
    
    /**
     Alert user with a message and segue to identified View Controller.
     - parameter message: of an alert.
     - parameter segueIdentifier: to perform segue with given SegueIdentifier.
     */
    private func alertToUserWithMesage(_ message: String, segueIdentifier: String) {
        let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default)
                                  { action -> Void in
                                    if segueIdentifier != "" {
                                        self.performSegue(withIdentifier: segueIdentifier, sender: self)
                                    }
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromAccountVCtoLogInVC"{
            let destinationVC = segue.destination as? LogInViewController
            if logOutMessage == "We logged you out for security purposes."{
                destinationVC?.logOutMessage = "We logged you out for security purposes."
            }
            destinationVC?.performeAnimate = false
        }
    }
}

