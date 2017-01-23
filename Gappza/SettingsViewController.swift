//
//  SettingsViewController.swift
//  Gapza
//
//  Created by Firdavsii Majidzoda on 11/8/16.
//  Copyright © 2016 Gappza. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    
    // MARK: Outlets
    @IBOutlet var account: UILabel!
    
    @IBOutlet var touchIdSwitch: UISwitch!
    
    @IBOutlet var contactUsButton: UIButton!
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    // MARK: Fields
    private var touchIDSwitchCheckBox: CheckBox!
    private var currentUser: User!
    private var isTouchIdActive: Bool?
    
    private var logOutMessage: String!
    private var logOutTimeSet: Date!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareforView()
        
        // Adding observers
        registerForEnterBackForGroundsObservers()
    }
    
    // Prepare for view
    func prepareforView() {
        currentUser = User()
        loadEmail()
        
        touchIdConfiguration()
    }
    
    //MARK: Log out when inactive Configuration
    /**
     Add observers for UIApplicationDidEnterBackground and UIApplicationWillEnterForeground with following selectors:
     - enterBackground()
     - enterForeground()
     */
    private func registerForEnterBackForGroundsObservers(){
        logOutMessage = ""
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
        if logOutTimeSet.timeIntervalSinceNow <= -15*60{
            logOutMessage = "We logged you out for security purposes."
            performSegue(withIdentifier: "fromSettingsVCtoLogInVC", sender: self)
        }
    }
    
    // MARK: Load email Configuration
    /**
        Load current user's email and set account UILabel text to loaded email
     */
    private func loadEmail(){
        account.text = currentUser.loadCurrentUserEmail()
    }
    
    // MARK: TouchId Configuration
    /**
        Create touchId Switch, and load and set the values
     */
    private func touchIdConfiguration(){
        touchIDSwitchCheckBox = CheckBox(archieveName: "touchIdSwitch.archieve", additionalArchieve: "touchIdEmail.archieve")
        
        touchIdSwitch.setOn(false, animated: true)
        isTouchIdActive = false
        loadTouchIdBoolean()
    }
    
    /**
        Load touchID boolean values to set the state of the Switch
     */
    private func loadTouchIdBoolean() {
        if touchIDSwitchCheckBox.isChecked! && currentUser.loadCurrentUserEmail() == touchIDSwitchCheckBox.loadAdditionalArchieve(){
            touchIdSwitch.setOn(true, animated: true)
        } else {
            touchIdSwitch.setOn(false, animated: true)
        }
    }
    
    /**
        Sve touchId switch values to default, when user deletes account
     */
    private func turnOffTouchId() {
        if touchIDSwitchCheckBox.loadCheckBoxValue() {
            touchIDSwitchCheckBox.saveAdditionalArchieve(archieveValue: "")
            touchIDSwitchCheckBox.saveCheckBoxValue(bool: false)
        }
    }
    
    /**
        Switch touchId Switch state, and save associated email with it.
     */
    @IBAction func touchIdSwitch(_ sender: UISwitch) {
        if touchIdSwitch.isOn {
            touchIDSwitchCheckBox.saveCheckBoxValue(bool: false)
            touchIdSwitch.setOn(false, animated:true)
            
        } else {
            touchIDSwitchCheckBox.saveCheckBoxValue(bool: true)
            touchIDSwitchCheckBox.saveAdditionalArchieve(archieveValue: currentUser.loadCurrentUserEmail())
            touchIdSwitch.setOn(true, animated:true)
        }
    }
    
    // MARK: Delete account Button Confiuration
    // MARK: API call
    /**
        Delete accoutn from Data Base, inform user, set touchId Switch values to default, Segue to LogInViewController
         - parameter sender: Delete account Button
     */
    @IBAction func deleteAccountButtonAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Are you sure you want to delete your account?", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default){
            action -> Void in
            self.startSpinnerAndResignTheView()
            
            GapzaAPI.deleteAccount(email: self.currentUser.loadCurrentUserEmail()){
                response in
                
                // Getting response status
                guard let status = response["status"] else {
                    // Can't get a response status
                    self.stopSpinnerAndAlertUser()
                    return
                }
                
                switch status{
                    
                case "1":
                    // Success, getting message
                    guard let message = response["message"] else {
                        // Can't get a token
                        self.stopSpinnerAndAlertUser()
                        return
                    }
                    self.stopSpinnerAndGetViewResponder()
                    self.turnOffTouchId()
                    self.alertToUserWithMesage(message, segueIdentifier: "fromSettingsVCtoLogInVC")
                    
                    
                case "-1":
                    // Failure, getting error message
                    guard let errorMessage = response["errorMessage"] else {
                        // Can't get error message
                        self.stopSpinnerAndAlertUser()
                        return
                    }
                    self.stopSpinnerAndGetViewResponder()
                    self.alertToUserWithMesage(errorMessage, segueIdentifier: "fromSettingsVCtoLogInVC")
                    
                default:break
                }
                
            }
            
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default){ action -> Void in })
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: Spinner ActivityIndicator Configuration
    /**
     Resign any subviews that is first responder and stop user interaction. Start spinner animation.
     */
    private func startSpinnerAndResignTheView() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        spinner.startAnimating()
    }
    
    /**
     Start user interaction and stop Spinner animation.
     */
    private func stopSpinnerAndGetViewResponder() {
        spinner.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    /**
     Start user interaction, stop Spinner animation and alert user with an error message and segue to LogInViewController
     */
    private func stopSpinnerAndAlertUser() {
        self.spinner.stopAnimating()
        if self.view.canBecomeFirstResponder {
            self.view.becomeFirstResponder()
        }
        self.alertToUserWithMesage("Uexpected error occured, please try again later.", segueIdentifier: "fromSettingsVCtoLogInVC")
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
        if segue.identifier == "fromSettingsVCtoLogInVC"{
            let destinationVC = segue.destination as? LogInViewController
            if logOutMessage == "We logged you out for security purposes."{
                destinationVC?.logOutMessage = "We logged you out for security purposes."
            }
            destinationVC?.performeAnimate = false
        }
    }
}

