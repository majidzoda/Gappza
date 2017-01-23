//
//  NewPasswordViewController.swift
//  Gapza
//
//  Created by Firdavsii Majidzoda on 11/8/16.
//  Copyright © 2016 Gappza. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet var currentPasswordErrorLabel: UILabel!
    @IBOutlet var currentPasswordTextField: UITextField!
    
    @IBOutlet var newPasswordErrorLabel: UILabel!
    @IBOutlet var newPasswordTextField: UITextField!
    
    @IBOutlet var confirmNewPasswordErrorLabel: UILabel!
    @IBOutlet var confirmNewPasswordTextField: UITextField!
    
    @IBOutlet var submitButton: UIButton!
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    
    // MARK: Fields
    private var newPassword: ChangePassword!
    private var user: User!
    private var touchIdCheckBox: CheckBox!
    
    private var logOutMessage: String!
    private var logOutTimeSet: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareForView()
        
        // Add observers
        registerForEnterBackForGroundsObservers()
    }
    
    // Prepare for view
    func prepareForView() {
        setAdditionalConfiguration()
        
        validateSubmitButton()
        
        setDelegations()
    }
    
    // MARK: Log out when inactive Configuration
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
    
    /**
        Congifure newPassword ChangePassword, user User and touchIdCheckBox if user changes password successfuly, touchId saves values to default
     */
    private func setAdditionalConfiguration(){
        newPassword = ChangePassword()
        user = User()
        touchIdCheckBox = CheckBox(archieveName: "touchIdSwitch.archieve", additionalArchieve: "touchIdEmail.archieve")
    }

    // MARK: Current Password TextField Configuration
    /**
     Set newPassword's Password and updates current password error and validates Submit Button when TextField's text change begin.
     - parameter sender: TextField to be edited
     */
    @IBAction func currentPasswordChangeBegin(_ sender: AnyObject) {
        newPassword.currentPassword = currentPasswordTextField.text
        currentPasswordErrorLabel.text = newPassword.validateCurrentPassword()
        validateSubmitButton()
    }
    
    /**
     Set newPassword's Password and updates current password error and validates Submit Button when TextField's text change.
     - parameter sender: TextField to be edited
     */
    @IBAction func currentPasswordDidChange(_ sender: AnyObject) {
        newPassword.currentPassword = currentPasswordTextField.text
        currentPasswordErrorLabel.text = newPassword.validateCurrentPassword()
        validateSubmitButton()
    }
    
    // MARK: New Password TextField Configuration
    /**
     Set newPassword's New Password and updates New password error and validates Submit Button when TextField's text change begin.
     - parameter sender: TextField to be edited
     */
    @IBAction func newPasswordChangeDidBegin(_ sender: AnyObject) {
        newPassword.newPassword = newPasswordTextField.text
        newPasswordErrorLabel.text = newPassword.validateNewPassword()
        validateSubmitButton()
    }
    
    /**
     Set newPassword's New Password and updates New password error and validates Submit Button when TextField's text change.
     - parameter sender: TextField to be edited
     */
    @IBAction func newPasswordDidChange(_ sender: AnyObject) {
        newPassword.newPassword = newPasswordTextField.text
        newPasswordErrorLabel.text = newPassword.validateNewPassword()
        validateSubmitButton()
    }
    
    /**
     Set newPassword's Confirm  Password and updates Confirm password error and validates Submit Button when TextField's text change begin.
     - parameter sender: TextField to be edited
     */
    @IBAction func confirmNewPasswordChangeBegin(_ sender: AnyObject) {
        newPassword.confirmNewPassword = confirmNewPasswordTextField.text
        confirmNewPasswordErrorLabel.text = newPassword.validateConfirmNewPassword()
        validateSubmitButton()
    }
    
    /**
     Set newPassword's Confirm Password and updates Confirm password error and validates Submit Button when TextField's text change.
     - parameter sender: TextField to be edited
     */
    @IBAction func confirmPasswordDidChange(_ sender: AnyObject) {
        newPassword.confirmNewPassword = confirmNewPasswordTextField.text
        confirmNewPasswordErrorLabel.text = newPassword.validateConfirmNewPassword()
        validateSubmitButton()
    }
    
    // MARK: TextFields delegations Configurations
    /**
     Set delegations to self for following:
     - currentPasswordTextField
     - newPasswordTextField
     - confirmNewPasswordTextField
     */
    private func setDelegations(){
        currentPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmNewPasswordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
     Tap on background resign any current first responder.
     */
    @IBAction func tapAction(_ sender: AnyObject) {
        let objects = [
            currentPasswordTextField,
            newPasswordTextField,
            confirmNewPasswordTextField
        ]
        
        for object in objects {
            if (object?.isFirstResponder)! {
                object?.resignFirstResponder()
            }
        }
    }
    
    /**
     Validate Submit Button
     */
    private func validateSubmitButton() {
        if newPassword.validateChangePassword() == "" {
            submitButton.isEnabled = true
            submitButton.setBackgroundImage(UIImage(named: "Button"), for: .normal)
        } else {
            submitButton.isEnabled = false
            submitButton.setBackgroundImage(UIImage(named: "Disabled Button"), for: .normal)
        }
    }
    
    /**
     Validate and update the following UILabelViews:
     - currentPasswordErrorLabel
     - newPasswordErrorLabel
     - confirmNewPasswordErrorLabel
     */
    private func updateErrors() {
        currentPasswordErrorLabel.text = newPassword.validateCurrentPassword()
        newPasswordErrorLabel.text = newPassword.validateNewPassword()
        confirmNewPasswordErrorLabel.text = newPassword.validateConfirmNewPassword()
        validateSubmitButton()
        
    }
    
    /**
        Save touchId values to default when user changes password
     */
    private func turnOffTouchId() {
        if touchIdCheckBox.loadCheckBoxValue() {
            touchIdCheckBox.saveAdditionalArchieve(archieveValue: "")
            touchIdCheckBox.saveCheckBoxValue(bool: false)
        }
    }
    
    
    
    // MARK: Submit Button Configuration
    // MARK: API call
    /**
        Validates current password:
         - call changePassword() if valid password
         - If invalid password, stop Spinner and alert user with a message.
     */
    @IBAction func submitButtonClicked(_ sender: UIButton) {
        let email  = user.loadCurrentUserEmail()
        
        if newPassword.validateNewPassword() == ""{
            startSpinnerAndResignTheView()
            
            GapzaAPI.validatePassword(["email":email, "password": currentPasswordTextField.text!.sha1()]){
                (response) -> Void in
                
                // Getting response status
                guard let status = response["status"] else {
                    // Can't get response status
                    self.stopSpinnerAndAlertUser()
                    return
                }
                
                switch status {
                    
                case "1":
                    // Success, current password is valid. Changing the password
                    self.changePassword()
                    
                case "-1":
                    // Failure, getting error message
                    self.stopSpinnerAndGetViewResponder()
                    self.alertToUserWithMesage("Incorrect password, enter a valid passowrd.", segueIdentifier: "")
                    
                default: break
                }
            }
        } else {
            updateErrors()
        }
        
    }
    
    /**
        Change password of a user, alert user dialog, save touchId values to default, Segue to LogInViewController
     */
    private func changePassword(){
        GapzaAPI.changePassword(["email":user.loadCurrentUserEmail(), "password":newPasswordTextField.text!.sha1()]){
            response in
            
            // Getting response status
            guard let status = response["status"] else {
                // Can't get response status
                self.stopSpinnerAndAlertUser()
                return
            }
            
            switch status {
                
            case "1":
                // Success, password updated
                guard let message = response["message"] else {
                    // Can't get message
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.turnOffTouchId()
                self.stopSpinnerAndGetViewResponder()
                self.alertToUserWithMesage(message, segueIdentifier: "fromChangePasswordVCtoLogInVC")
                
            case "-1":
                // Failure, getting error message
                self.alertToUserWithMesage("Incorrect password, enter a valid passowrd.", segueIdentifier: "")
                
            default: break
            }
        }
    }
    
    // MARK: Spinner ActivityIndicator Configuration
    /**
     Resign any subviews that is first responder and stop user interaction. Start spinner animation.
     */
    private func startSpinnerAndResignTheView() {
        let objects = [
            currentPasswordTextField,
            newPasswordTextField,
            confirmNewPasswordTextField,
            submitButton
        ]
        
        for object in objects {
            if (object?.isFirstResponder)! {
                object?.resignFirstResponder()
            }
        }
        
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
        self.alertToUserWithMesage("Uexpected error occured, please try again later.", segueIdentifier: "fromChangePasswordVCtoLogInVC")
    }
    
    
    /**
    Alert user with a message and segue to identified View Controller.
    - parameter message: of an alert.
    - parameter segueIdentifier: to perform segue with given SegueIdentifier.
    */
    func alertToUserWithMesage(_ message: String, segueIdentifier: String) {
        let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default)
                                  { action -> Void in
                                    if segueIdentifier != "" {
                                        self.performSegue(withIdentifier: segueIdentifier, sender: self)
                                    }
                                    
        })
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    // Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromChangePasswordVCtoLogInVC"{
            let destinationVC = segue.destination as? LogInViewController
            if logOutMessage == "We logged you out for security purposes."{
                destinationVC?.logOutMessage = "We logged you out for security purposes."
            }
            destinationVC?.performeAnimate = false
        }
    }
    
}

