//
//  LogInViewController.swift
//  Gappza
//
//  Created by Firdavsii Majidzoda on 11/8/16.
//  Copyright © 2016 Gappza. All rights reserved.
//

import UIKit
import LocalAuthentication
import CryptoSwift

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var rememberMeCheckBoxButton: UIButton!
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var forGotPasswordButton: UIButton!
    
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var touchIDTexLabel: UILabel!
    @IBOutlet var touchIdButton: UIButton!
    
    @IBOutlet var innerView: UIView!
    
    @IBOutlet var outterView: UIView!
    
    @IBOutlet var logo: UIImageView!
    
    @IBOutlet var logoTopToSuperViewTop: NSLayoutConstraint!
    
    
    // MARK: Fields
    private var rememberMeCheckBox: CheckBox!
    private var touchIdCheckBox: CheckBox!
    private var currentUser: User!
    var logOutMessage = ""
    var performeAnimate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareForView()
    }
    
    // MARK: Prepare For View
    /**
        Prepares and configures subviews.
     */
    private func prepareForView(){
        // If App is first launched
        if performeAnimate {
            animateViewToPosition()
        }
        
        forGotPasswordButton.isEnabled = false
        signInButton.isEnabled = false
        
        // Initialize Remember me CheckBox, Touch ID CheckBox and currentUser User
        rememberMeCheckBox = CheckBox(archieveName: "logInVCrememberMeCheckBoxArchieve.archieve", additionalArchieve: "logInVCemailArchieve.archieve")
        touchIdCheckBox = CheckBox(archieveName: "touchIdSwitch.archieve", additionalArchieve: "touchIdEmail.archieve")
        currentUser = User()
        
        // Configure SubViews
        loadCheckBox()
        checkTouchIdDetails()
        validateUpdates()
        setDelegations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // When user was logged in and inactive more than 15 minutes
        if logOutMessage == "We logged you out for security purposes."{
            alertToUserWithMesage(logOutMessage, segueIdentifier: "")
        }
    }

    /**
        Animates Logo, starting from center to top.
     */
    private func animateViewToPosition() {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            self.innerView.frame.origin.y -= self.innerView.frame.height/2-self.logoTopToSuperViewTop.constant-self.logo.frame.height/2
        }, completion: {
            isFinished in
            if isFinished{
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        })
    }
    
    
    //MARK: Email UITextField Configuration
    /**
        Update state of the following after email UITextField text change:
         - rememberMeCheckBox CheckBox: Save email if rememberMeCheckBox is checked.
         - validateUpdates(): Validate all for Log in Button.
         - validateTouchIdButton(): Enable touchId Button if current email matches touchId's associated saved email.
     */
    @IBAction func emailTextFieldDidChange(_ sender: AnyObject) {
        rememberMeCheckBox.saveAdditionalArchieve(archieveValue: emailTextField.text!.lowercased())
        validateUpdates()
        validateTouchIdButton()
    }
    
    /**
     Update state of the following when email UITextField text change begin:
     - rememberMeCheckBox CheckBox: Save email if rememberMeCheckBox is checked.
     - validateUpdates(): Validate all for Log in Button.
     - validateTouchIdButton(): Enable touchId Button if current email matches touchId's associated saved email.
     */
    @IBAction func emailTextFieldDidBegin(_ sender: AnyObject) {
        rememberMeCheckBox.saveAdditionalArchieve(archieveValue: emailTextField.text!.lowercased())
        validateUpdates()
        validateTouchIdButton()
    }
    
    /**
     Update state of the following after email UITextField text change ended:
     - rememberMeCheckBox CheckBox: Save email if rememberMeCheckBox is checked.
     - validateUpdates(): Validate all for Log in Button.
     - validateTouchIdButton(): Enable touchId Button if current email matches touchId's associated saved email.
     */
    @IBAction func emailTextFieldDidEnd(_ sender: UITextField) {
        rememberMeCheckBox.saveAdditionalArchieve(archieveValue: emailTextField.text!.lowercased())
        validateUpdates()
        validateTouchIdButton()
    }
    
    
    // MARK: Remember me CheckBox Configurations
    /**
       Load check box values:
        - isChecked: boolean to set CheckBox state
        - additionalArchiveValue: to set email UITextField text
     */
    private func loadCheckBox() {
        if rememberMeCheckBox.isChecked! {
            rememberMeCheckBoxButton.setImage(UIImage(named: "checkbox"), for: UIControlState())
            emailTextField.text = rememberMeCheckBox.additionalArchieveValue
        } else {
            rememberMeCheckBoxButton.setImage(UIImage(named: "disable checkbox"), for: UIControlState())
        }
    }
    
    /**
        Save rememberMeCheckBox state
        - parameter isChecked: (Boolean) Is CheckBox checked or not.
     */
    private func saveCheckBox(_ isChecked: Bool) {
        rememberMeCheckBox.saveCheckBoxValue(bool: isChecked)
    }
    
    /**
        Save email for rememberMeCheckBox if CheckBox state is checked.
     */
    private func saveEmail() {
        rememberMeCheckBox.saveAdditionalArchieve(archieveValue: emailTextField.text!.lowercased())
    }
    
    /**
        Switch rememberMeCheckBox state when clicked and save it's state and email if checked:
         - isChecked (true <-> false)
         - Update CheckBox background picture.
         - saveCheckBox(): Save CheckBox state and email if it is checked.
     */
    @IBAction func rememberMeCheckBoxClicled(_ sender: UIButton) {
        print(self.description+" "+#function+"(function)")
        print(#function)
        if rememberMeCheckBox.isChecked! {
            rememberMeCheckBoxButton.setImage(UIImage(named: "disable checkbox"), for: UIControlState())
            saveCheckBox(false)
        } else {
            rememberMeCheckBoxButton.setImage(UIImage(named: "checkbox"), for: UIControlState())
            saveCheckBox(true)
            saveEmail()
        }
    }
    
    
    // MARK: Password UITextField Configuration
    /**
     Update and validate all after password UITextField text change begin:
     - validateUpdates(): Validate all for Log in Button.
     */
    @IBAction func passwordTextFieldDidBegin(_ sender: UITextField) {
        validateUpdates()
    }
    
    /**
     Update and validate all after password UITextField text changed:
     - validateUpdates(): Validate all for Log in Button.
     */
    @IBAction func passwordTextFieldDidChange(_ sender: UITextField) {
        validateUpdates()
    }
    
    /**
     Update and validate all after password UITextField text change ended:
     - validateUpdates(): Validate all for Log in Button.
     */
    @IBAction func passwordTextFieldDidEnd(_ sender: UITextField) {
        validateUpdates()
    }
    
    
    // MARK: TextField deligations Configuration
    /**
        Set emailTextField and passwordTextField delegations to self.
     */
    private func setDelegations() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
        Tap on background resign any current first responder.
     */
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        let objects = [
            emailTextField,
            passwordTextField,
            ]
        
        for obj in objects {
            if (obj?.isFirstResponder)!{
                obj?.resignFirstResponder()
            }
        }
    }
    
    
    // MARK: Forgot passowrd Button Configuration
    /**
        Calls  forGotPassword() function for API calls to generate random temproray password and inform user.
        - parameter sender:  - forgotPassword Button
     */
    @IBAction func forgotPasswordClicled(_ sender: UIButton) {
        forGotPassword()
    }
    
    
    // MARK: Signin in Button Configuration
    /**
        Sign in user, stop user interaction, start spinner animation and Check for account validation.
         - startSpinnerAndResignTheView(): Stops all user interaction, starts Spinner Animation and setVisible.
         - checkIfAccountExist(): make and API Call to check if account exist.
     */
    @IBAction func signInButtonClicked(_ sender: UIButton) {
        startSpinnerAndResignTheView()
        
        // Checking for valid account
        checkIfAccountExist()
    }
    
    
    // MARK: touchID Button and info UILabel Configurations
    /**
        If touchId Switch is has been set on in SettingsVC | off:
         - touchIdButton enable = true                  | false
         - touchIdButton background picture: enable pic | disable pic
         - touchIdTextLabel: ""                         | "Sign in to enable Touch ID"
     */
    private func checkTouchIdDetails() {
        if touchIdCheckBox.isChecked!{
            if isTouchIdEmailMatch() {
                touchIdButton.isEnabled = true
                touchIdButton.setImage(UIImage(named: "Touch ID Icon"), for: UIControlState())
                touchIDTexLabel.text = ""
            } else {
                touchIdButton.isEnabled = false
                touchIdButton.setImage(UIImage(named: "Disable Touch ID Icon"), for: UIControlState())
                touchIDTexLabel.text = "Sign in to enable Touch ID"
            }
            
        } else {
            touchIdButton.isEnabled = false
            touchIdButton.setImage(UIImage(named: "Disable Touch ID Icon"), for: UIControlState())
            touchIDTexLabel.text = "Sign in to enable Touch ID"
        }
        
    }
    
    /**
        Check if current email in UItextField matches the saved email associated with touchId.
        - returns: true or false
     */
    private func isTouchIdEmailMatch() -> Bool {
        if emailTextField.hasText && emailTextField.text?.lowercased() == touchIdCheckBox.additionalArchieveValue {
            return true
        } else {
            return false
        }
    }
    
    /**
        Validates touchId Button and enables it if emails match and touchId has been turn on in SettingsVC.
     */
    private func validateTouchIdButton(){
        if isTouchIdEmailMatch(){
            touchIdButton.isEnabled = true
            touchIdButton.setImage(UIImage(named: "Touch ID Icon"), for: UIControlState())
            touchIDTexLabel.text = ""
        } else {
            touchIdButton.isEnabled = false
            touchIdButton.setImage(UIImage(named: "Disable Touch ID Icon"), for: UIControlState())
            touchIDTexLabel.text = "Sign in to enable Touch ID"
        }
    }
    
    /**
        Disable touchId and sets default value when forgot password clicked.
     */
    private func turnOffTouchId() {
        print(self.description+" "+#function)
        if touchIdCheckBox.isChecked! {
            touchIdCheckBox.saveAdditionalArchieve(archieveValue: "")
            touchIdCheckBox.saveCheckBoxValue(bool: false)
            checkTouchIdDetails()
        }
    }
    
    
    // MARK: Validate all Configuration
    /**
        Validates email and password TextFields and forgot password and Sign in Buttons.
     */
    private func validateUpdates(){
        if validatePasswordTextField() && validateEmailTextField() {
            forGotPasswordButton.isEnabled = true
            forGotPasswordButton.setTitleColor(UIColor.white, for: UIControlState())
            signInButton.isEnabled = true
            signInButton.setBackgroundImage(UIImage(named: "Button"), for: .normal)
        } else if validateEmailTextField() {
            forGotPasswordButton.isEnabled = true
            forGotPasswordButton.setTitleColor(UIColor.white, for: UIControlState())
            signInButton.isEnabled = false
            signInButton.setBackgroundImage(UIImage(named: "Disabled Button"), for: .normal)
        } else {
            signInButton.isEnabled = false
            signInButton.setBackgroundImage(UIImage(named: "Disabled Button"), for: .normal)
            forGotPasswordButton.isEnabled = false
            forGotPasswordButton.setTitleColor(UIColor.gray, for: UIControlState())
        }
        
    }
    
    /**
        Check for emailTextField' text validation.
        - returns: true or false
     */
    private func validateEmailTextField() -> Bool{
        if emailTextField.hasText {
            if emailTextField.text == "" {
                return false
            } else {
                return isValidEmail(emailTextField.text!)
            }
        } else {
            return false
        }
    }
    
    /**
        Validate email string with email format.
        - parameter testStr: email string to be checked
        - returns: true or false
     */
    fileprivate func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    private func validatePasswordTextField() -> Bool {
        if passwordTextField.hasText {
            if passwordTextField.text == ""{
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    
    
    // MARK: touchID SighnIn Configuration
    /**
        Execute touchId regcognitio, sign in if matches alert an error if doesn't match.
        - parameter sender: touchId UIButton
     */
    @IBAction func touchIdButtonAction(_ sender: UIButton) {
        
        let authenticationContext = LAContext()
        var error: NSError?
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            showAlertViewIfNoBiometricSensorHasBeenDetected()
            return
        }
        
        authenticationContext.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Log in to view your account",
            reply: { [unowned self] (success, error) -> Void in
                if( success ) {
                    // Fingerprint recognized
                    OperationQueue.main.addOperation {
                        if self.isTouchIdEmailMatch(){
                            self.currentUser.saveEmailForCurrentUser(email: (self.emailTextField.text?.lowercased())!)
                            self.performSegue(withIdentifier: "fromLogInVCToAccountVC", sender: self)
                        } else {
                            
                        }
                    }
                }else {
                    // Check if there is an error
                    if let error = error as? NSError {
                        let message = self.errorMessageForLAErrorCode(errorCode: error.code)
                        self.showAlertViewAfterEvaluatingPolicyWithMessage(message)
                    }
                }
        })
    }
    
    /**
        Alert user with an error message.
        - parameter message: to be shown to user
     */
    private func showAlertViewAfterEvaluatingPolicyWithMessage( _ message:String ){
        showAlertWithTitle("Error", message: message)
    }
    
    /**
        Alert user when with message when device has not a touchId sensor.
     */
    private func showAlertViewIfNoBiometricSensorHasBeenDetected(){
        showAlertWithTitle("Error", message: "This device does not have a TouchID sensor.")
    }
    
    /**
        Alert user with title and message at touchId recognition process.
        - parameter title: of an alert
        - parameter message: to be shown to a user
     */
    private func showAlertWithTitle( _ title:String, message:String ) {
        if message != "The user did cancel" && message != "The user chose to use the fallback"{
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertVC.addAction(okAction)
            
            DispatchQueue.main.async { () -> Void in
                
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    /**
        Segue to AccountVC when touchId has been recognized.
     */
    private func navigateToAuthenticatedViewController(){
        self.performSegue(withIdentifier: "navigateToAccountVC", sender: self)
    }
    
    /**
        Convert Int error to String messages.
        - parameter errorCode: touchId Int error code to be converted
        - returns: String message
     */
    private func errorMessageForLAErrorCode(errorCode:Int ) -> String{
        var message = ""
        switch errorCode {
            
        case LAError.Code.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.Code.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.Code.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.Code.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.Code.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.Code.touchIDLockout.rawValue:
            message = "Too many failed attempts."
            
        case LAError.Code.touchIDNotAvailable.rawValue:
            message = "TouchID is not available on the device"
            
        case LAError.Code.userCancel.rawValue:
            message = "The user did cancel"
            //
            
        case LAError.Code.userFallback.rawValue:
            //
            message = "The user chose to use the fallback"
            
        default:
            break
            
        }
        return message
    }
    
    
    // MARK: API calls Configuration
    /**
        Checks if given account exist in Data Base.
         - When exist: call checkIfAccountActivated() function for account activation check
         - When doesn't exist: Stops Spinner and alert user with a message.
     */
    private func checkIfAccountExist() {
        
        GapzaAPI.validateEmail(email: emailTextField.text!.lowercased()){
            (response) -> Void in
            
            // Getting response status
            guard let status = response["status"] else {
                // Ccan't get a status
                self.stopSpinnerAndAlertUser()
                return
            }
            
            switch status {
                
            case "1":
                // Account doesn't exist
                self.stopSpinnerAndGetViewResponder()
                
                //  Getting error message
                guard let errorMessage = response["message"] else {
                    // Can't get an error message
                    self.alertToUserWithMesage("Unexpected error occured, please try again later.", segueIdentifier: "")
                    return
                }
                self.alertToUserWithMesage(errorMessage, segueIdentifier: "")
                
            case "-1":
                // Account exist check if it is activated
                self.checkIfAccountActivated()
            case "0":
                self.stopSpinnerAndAlertUser()
                
            default:break
            }
        }
    }
    
    /**
        Checks if given account is activated.
         - When account is activated: call validatePassword() function to check if password is valid.
         - When accoint is not activated: Stops Spinner and alert user with a message.
     */
    private func checkIfAccountActivated() {
        GapzaAPI.validateActivation(email: emailTextField.text!.lowercased()){
            (response) -> Void in
            
            // Getting response status
            guard let status = response["status"] else {
                self.stopSpinnerAndAlertUser()
                return
            }
            
            switch status {
                
            case "1":
                // Account is activated, checking for valid password
                self.validatePassword()
                
            case "-1":
                // Account is not activated, getting error message
                guard let errorMessage = response["errorMessage"] else {
                    // Can't get an error essage
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.stopSpinnerAndGetViewResponder()
                self.alertToUserWithMesage(errorMessage, segueIdentifier: "")
                
            default:break
            }
        }
    }
    
    /**
        Check if password is valid for given account.
         - When password is valid: Stops spinner and enables user interaction then segues to AccountVC.
         - When password is invalid: Stops Spinner and alert user with a message.
     */
    private func validatePassword() {
        GapzaAPI.validatePassword(["email":emailTextField.text!.lowercased(), "password": passwordTextField.text!.sha1()]){
            (response) -> Void in
            
            // Getting response status
            guard let status = response["status"] else {
                // Can't get response status
                self.stopSpinnerAndAlertUser()
                return
            }

            switch status {
                
            case "1":
                // Valid passowrd, access granted, go to account
                self.stopSpinnerAndGetViewResponder()
                self.currentUser.saveEmailForCurrentUser(email: self.emailTextField.text!.lowercased())
                self.performSegue(withIdentifier: "fromLogInVCToAccountVC", sender: self)
                
            case "-1":
                // Invalid passowrd, getting error message
                self.stopSpinnerAndGetViewResponder()
                guard let errorMessage = response["errorMessage"] else {
                    // Can't get an error message
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.alertToUserWithMesage(errorMessage, segueIdentifier: "")
                
            default: break
            }
        }
    }
    
    
    /**
        Call GapzaAPI.validateEmail(email: emailTextField.text!.lowercased()) to check if given account exist.
        - If account exist: call getUsersFirstName() function to get user's first name.
        - If account doesn't exist: Stops Spinner and alert user with a message.
     */
    private func forGotPassword(){
        startSpinnerAndResignTheView()
        GapzaAPI.validateEmail(email: emailTextField.text!.lowercased()){
            (response) -> Void in
            
            // Getting response status
            guard let status = response["status"] else {
                // Can't get response status
                self.stopSpinnerAndAlertUser()
                return
            }
            
            switch status {
                
            case "1":
                // Account doesn't exist, getting error message
                self.stopSpinnerAndGetViewResponder()
                self.alertToUserWithMesage("Invalid account.", segueIdentifier: "")
                
            case "-1":
                // Account exist, calling to generate temprorary password
                self.getUsersFirstName()
                
            case "0":
                self.stopSpinnerAndAlertUser()
            default:break
            }
        }
 
    }
    
    /**
        Get user's first name and call forgotPassword(firstName: firstName) passing first name as an parameter.
     */
    private func getUsersFirstName(){
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
                self.forgotPassword(firstName: firstName)
                
               
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
        Genereate random temproray password and encrypt it. Then turns off touchID feature then informs via email. Alert user with a message about completion of process.
        - parameter firstName: to include in infroming email to greet a user.
     */
    private func forgotPassword(firstName: String) {
        
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.second,.nanosecond], from: date)
        let tempPass = (components.second?.description)!+(components.nanosecond?.description)!
        let hashTempPassword = tempPass.sha1()
        
        GapzaAPI.forGotPassword(email: emailTextField.text!.lowercased(), hashPass: hashTempPassword, tempPass: tempPass, firstName: firstName){
            response in
            
            // Getting response status
            guard let status = response["status"] else {
                // Can't get response status
                self.stopSpinnerAndAlertUser()
                return
            }
            
            switch status {
                
            case "1":
                // Success, getting response message
                guard let message = response["message"] else {
                    // Can't get a message
                    self.stopSpinnerAndAlertUser()
                    return
                }
                
                // Turn off touchId for user.
                self.turnOffTouchId()
                self.stopSpinnerAndGetViewResponder()
                self.alertToUserWithMesage(message, segueIdentifier: "")
                
            case "-1":
                // Failure, getting error message
                guard let errorMessage = response["errorMessage"] else {
                    // Can't get error message
                    self.stopSpinnerAndAlertUser()
                    return
                }
                
                self.alertToUserWithMesage(errorMessage, segueIdentifier: "")
                
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
            emailTextField,
            rememberMeCheckBoxButton,
            passwordTextField,
            forGotPasswordButton,
            signInButton,
            signUpButton,
            touchIdButton
        ]
        
        for object in objects {
            if (object!.isFirstResponder){
                object!.resignFirstResponder()
            }
        }
        UIApplication.shared.beginIgnoringInteractionEvents()
        spinner.startAnimating()
    }
    
    /**
        Start user interaction and stop Spinner animation.
     */
    private func stopSpinnerAndGetViewResponder() {
        UIApplication.shared.endIgnoringInteractionEvents()
        spinner.stopAnimating()
    }
    
    /**
        Start user interaction, stop Spinner animation and alert user with an error message.
     */
    private func stopSpinnerAndAlertUser() {
        spinner.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        self.alertToUserWithMesage("Uexpected error occured, please try again later.", segueIdentifier: "")
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
}

