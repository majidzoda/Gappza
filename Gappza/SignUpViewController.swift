//
//  SignUpViewController.swift
//  Gappza
//
//  Created by Firdavsii Majidzoda on 11/8/16.
//  Copyright © 2016 Gappza. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet var firstNameErrorLabel: UILabel!
    @IBOutlet var firstNameTextField: UITextField!
    
    @IBOutlet var lastNameErrorLabel: UILabel!
    @IBOutlet var lastNameTextField: UITextField!
    
    @IBOutlet var phoneNumberErrorLabel: UILabel!
    @IBOutlet var phoneNumberTextField: UITextField!
    
    @IBOutlet var emailErrorLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var userNameLabel: UILabel!
    
    @IBOutlet var passwordErrorLabel: UILabel!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var confirmPasswordErrorLabel: UILabel!
    @IBOutlet var confirmPasswordTextField: UITextField!
    
    @IBOutlet var termsAndConditionsButton: UIButton!
    
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    // MARK: Fields
    private var activeField: UITextField?
    private var keyboardSize:CGSize?
    
    var newCostumer: Customer = Customer()
    var loadCustomer = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        
        prepareForView()
    }
    
    // MARK: Prepare For View
    /**
     Prepares and configures subviews.
     */
    private func prepareForView() {
        // Get customer and load Terms Adn Condittion CheckBox state if Seguing from TermsAndConditionVC or PrivacyPolicyVC
        getCustomer()
        loadTermsConditions()
        
        // Other configurations
        setDelegations()
        validateSignUbButton()
    }
    
    /**
     Get customer if Seguing from:
      - TermsAndConditionVC
      - PrivacyPolicyVC
     */
    private func getCustomer(){
        if loadCustomer {
            firstNameTextField.text = newCostumer.firstName
            lastNameTextField.text = newCostumer.lastName
            phoneNumberTextField.text = newCostumer.phoneNumber
            emailTextField.text = newCostumer.email
            
            if newCostumer.firstName != "" {
                firstNameErrorLabel.text = newCostumer.validateFirstName()
            }
            if newCostumer.lastName != "" {
                lastNameErrorLabel.text = newCostumer.validateLastName()
            }
            if newCostumer.phoneNumber != "" {
                phoneNumberErrorLabel.text = newCostumer.validatePhoneNumber()
            }
            if newCostumer.email != "" {
                emailErrorLabel.text = newCostumer.validateEmail()
            }
            validateSignUbButton()
        }
    }
    
    /**
     Load Terms Adn Condittion CheckBox state if Seguing from:
     - TermsAndConditionVC
     - PrivacyPolicyVC
     */
    private func loadTermsConditions() {
        if newCostumer.isTermsAndConditionChecked! {
            termsAndConditionsButton.setImage(UIImage(named: "checkbox"), for: UIControlState())
        } else {
            termsAndConditionsButton.setImage(UIImage(named: "disable checkbox"), for: UIControlState())
        }
        validateSignUbButton()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    // MARK: Keyboard moves scroll view Configuration
    /**
        Add observer anytime keyboard appears with following selectors:
         - keyboardWasShown()
         - keyboardWillBeHidden()
     */
    private func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /**
        Removes keyboard observer
     */
    private func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /**
        Scroll up view with keyboard height.
        - parameter notification: keyboard appearing observer notification
     */
    func keyboardWasShown(_ notification: Notification){
        //Need to calculate keyboard exact size
        self.scrollView.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        var position = activeField?.frame
        position?.origin.y += (activeField?.frame.height)!
        
        if activeField != nil
        {
            if (!aRect.contains((position?.origin)!))
            {
                scrollView.setContentOffset(CGPoint(x: 0, y: (keyboardSize?.height)!), animated: true)
            }
        }
    }
    
    /**
     Scroll down view with keyboard height.
     - parameter notification: keyboard disapearing observer notification
     */
    func keyboardWillBeHidden(_ notification: Notification){
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
    
    // MARK: First Name TextField Configuration
    /**
     Set customer First name and updates firstName error and validates Sign in Button when TextField's text change begin.
        - parameter sender: TextField to be indetified as active
     */
    @IBAction func firstNameTextFieldChangeDidBegin(_ sender: AnyObject) {
        newCostumer.firstName = firstNameTextField.text
        firstNameErrorLabel.text = newCostumer.validateFirstName()
        validateSignUbButton()
        activeField = sender as? UITextField
    }
    
    /**
     Set customer First name and updates firstName error and validates Sign in Button when TextField's text change.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func firstNameFieldDidChange(_ sender: AnyObject) {
        newCostumer.firstName = firstNameTextField.text
        firstNameErrorLabel.text = newCostumer.validateFirstName()
        validateSignUbButton()
        activeField = sender as? UITextField
    }
    
    
    // MARK: Last Name TextField Configuration
    /**
     Set customer Last name and updates lastName error and validates Sign in Button when TextField's text change begin.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func lastNameTextFieldChangeDidBegin(_ sender: AnyObject) {
        newCostumer.lastName = lastNameTextField.text
        lastNameErrorLabel.text = newCostumer.validateLastName()
        validateSignUbButton()
    }
    
    /**
     Set customer Last name and updates lastName error and validates Sign in Button when TextField's text change.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func lastNameTextFieldDidChange(_ sender: AnyObject) {
        newCostumer.lastName = lastNameTextField.text
        lastNameErrorLabel.text = newCostumer.validateLastName()
        validateSignUbButton()
        activeField = sender as? UITextField
    }
    
    
    // MARK: Phone Number TextField Configuration
    /**
     Set customer Phone number and updates phoneNumber error and validates Sign in Button when TextField's text change begin.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func phoneNumberTextFieldChangeDidBegin(_ sender: AnyObject) {
        newCostumer.phoneNumber = phoneNumberTextField.text
        phoneNumberErrorLabel.text = newCostumer.validatePhoneNumber()
        validateSignUbButton()
        activeField = sender as? UITextField
    }
    
    /**
     Set customer Phone number and updates phoneNumber error and validates Sign in Button when TextField's text change.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func phoneNumberTextFieldDidChange(_ sender: AnyObject) {
        newCostumer.phoneNumber = phoneNumberTextField.text
        phoneNumberErrorLabel.text = newCostumer.validatePhoneNumber()
        validateSignUbButton()
        activeField = sender as? UITextField
    }
    
    
    // MARK: Email TextField Configuration
    /**
     Set customer email, customer username and updates emailError error and validates Sign in Button when TextField's text change begin.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func emailTextFieldChangeDidBegin(_ sender: AnyObject) {
        newCostumer.email = emailTextField.text
        emailErrorLabel.text = newCostumer.validateEmail()
        if newCostumer.validateEmail() == "" {
            userNameLabel.text = emailTextField.text
        }
        validateSignUbButton()
        activeField = sender as? UITextField
    }
    
    /**
     Set customer email, customer username and updates emailError error and validates Sign in Button when TextField's text change.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func emailTextFieldDidChange(_ sender: AnyObject) {
        newCostumer.email = emailTextField.text
        emailErrorLabel.text = newCostumer.validateEmail()
        if newCostumer.validateEmail() == "" {
            userNameLabel.text = emailTextField.text
        }
        validateSignUbButton()
        activeField = sender as? UITextField
    }
    
    // MARK: Password TextField Configuration
    /**
     Set customer Password and updates password error and validates Sign in Button when TextField's text change begin.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func passwordTextFieldChangeDidBegin(_ sender: AnyObject) {
        newCostumer.password = passwordTextField.text
        passwordErrorLabel.text = newCostumer.validatePassword()
        validateSignUbButton()
        activeField = sender as? UITextField
    }
    
    /**
     Set customer Password and updates password error and validates Sign in Button when TextField's text change.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func passwordTextFieldDidChange(_ sender: AnyObject) {
        newCostumer.password = passwordTextField.text
        passwordErrorLabel.text = newCostumer.validatePassword()
        validateSignUbButton()
        activeField = sender as? UITextField
    }
    
    
    // MARK: Confirm Password TextField Configuration
    /**
     Set customer Confirm Password and updates confirmPassword error and validates Sign in Button when TextField's text change begin.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func confirmPasswordTextFieldChangeDidBegin(_ sender: AnyObject) {
        newCostumer.confirmPassword = confirmPasswordTextField.text
        confirmPasswordErrorLabel.text = newCostumer.validateConfirmPassword()
        validateSignUbButton()
        activeField = sender as? UITextField
    }
    
    /**
     Set customer Confirm Password and updates confirmPassword error and validates Sign in Button when TextField's text change.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func confirmPasswordTextFieldDidChange(_ sender: AnyObject) {
        newCostumer.confirmPassword = confirmPasswordTextField.text
        confirmPasswordErrorLabel.text = newCostumer.validateConfirmPassword()
        validateSignUbButton()
        activeField = sender as? UITextField
    }
    
    
    // MARK: TextFields delegations Configurations
    /**
        Set delegations to self for following:
         - firstNameTextField
         - lastNameTextField
         - phoneNumberTextField
         - emailTextField
         - passwordTextField
         - confirmPasswordTextField
     */
    private func setDelegations(){
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        phoneNumberTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
     Tap on background resign any current first responder.
     */
    @IBAction func tapOnView(_ sender: AnyObject) {
        let objects = [
            firstNameTextField,
            lastNameTextField,
            phoneNumberTextField,
            emailTextField,
            passwordTextField,
            confirmPasswordTextField
        ]
        
        for object in objects {
            if (object?.isFirstResponder)! {
                object?.resignFirstResponder()
            }
        }
    }
    
    // MARK Terms and Conditions CheckBox Configuration
     /**
     Switch termsAndConditionsCheckBox state when clicked:
     - isChecked (true <-> false)
     - Update CheckBox background picture.
     - Update Sign up Button state
     */
    @IBAction func termsAndConditionButtonAction(_ sender: UIButton) {
        if newCostumer.isTermsAndConditionChecked! {
            termsAndConditionsButton.setImage(UIImage(named: "disable checkbox"), for: UIControlState())
            newCostumer.isTermsAndConditionChecked = false
        } else {
            termsAndConditionsButton.setImage(UIImage(named: "checkbox"), for: UIControlState())
            newCostumer.isTermsAndConditionChecked = true
        }
        validateSignUbButton()
    }
    
    
    // MARK: Sign up Button Configuration
    @IBAction func signUp(_ sender: UIButton) {
        signUp()
    }

    
    /**
        Validate and update the following UILabelViews:
         - firstNameErrorLabel
         - lastNameErrorLabel
         - phoneNumberErrorLabel
         - emailErrorLabel
         - passwordErrorLabel
         - confirmPasswordErrorLabel
     */
    private func updateErrors() {
        firstNameErrorLabel.text = newCostumer.validateFirstName()
        lastNameErrorLabel.text = newCostumer.validateLastName()
        phoneNumberErrorLabel.text = newCostumer.validatePhoneNumber()
        emailErrorLabel.text = newCostumer.validateEmail()
        passwordErrorLabel.text = newCostumer.validatePassword()
        confirmPasswordErrorLabel.text = newCostumer.validateConfirmPassword()
    }
    
    /**
        Validate Sign up Button
     */
    private func validateSignUbButton(){
        if newCostumer.validateCustomer() == ""{
            signUpButton.isEnabled = true
            signUpButton.setBackgroundImage(UIImage(named: "Button"), for: .normal)
        } else {
            signUpButton.isEnabled = false
            signUpButton.setBackgroundImage(UIImage(named: "Disabled Button"), for: .normal)
        }
    }
    
    
    // MARK: API calls Configuration
    /**
        If no errors, validate customer's email:
         - If email is available call createAccount()
         - If email is taken stops Spinner and alert user with a message.
     */
    private func signUp(){
        startSpinnerAndResignTheView()
        if newCostumer.validateCustomer() == ""{
            
            // Customer details are valid to sign up for a new account
        
            let params = [
                "firstName": firstNameTextField.text!,
                "lastName": lastNameTextField.text!,
                "phoneNumber": phoneNumberTextField.text!,
                "email": emailTextField.text!.lowercased(),
                "password": passwordTextField.text!.sha1(),
                "date": newCostumer.date!
            ]
            
            // Checking if given email is available
            GapzaAPI.validateEmail(email: emailTextField.text!.lowercased()) {
                (response) -> Void in
                
                // Getting status response
                guard let status = response["status"] else {
                    // Can't get a status
                    self.stopSpinnerAndAlertUser()
                    return
                }
                
                switch status {
                    
                case "1":
                    // Given email is available, creating account
                    self.createAccount(params: params)
                    
                case "-1":
                    // Given email is already taken, getting error message
                    self.stopSpinnerAndGetViewResponder()
                    guard let errorMessage = response["message"] else {
                        // Can't get an error message
                        self.stopSpinnerAndAlertUser()
                        return
                    }
                    self.stopSpinnerAndGetViewResponder()
                    self.alertToUserWithMesage(errorMessage, segueIdentifier: "")
                    
                case "0":
                    self.stopSpinnerAndAlertUser()
                default: break
                }
            }
        } else {
            // Given details are not valid to register a new account, update errors
            updateErrors()
            stopSpinnerAndAlertUser()
        }
    }
    
    /**
        Create an account in Data Base and alert user with a message.
        - parameter params: Customer details for regestration
     */
    fileprivate func createAccount(params: [String: String]){
        
        GapzaAPI.createNewAccount(params){
            (response) -> Void in
            
            // Getting response status
            guard let status = response["status"] else {
                // Can't get a status response
                self.stopSpinnerAndAlertUser()
                return
            }
            
            switch status{
                
            case "1":
                // Success, getting messgae response
                self.stopSpinnerAndGetViewResponder()
                
                guard let message = response["message"] else {
                    // Can't get a message repsonse
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.alertToUserWithMesage(message, segueIdentifier: "fromSignUpVCtoLogInVC")
                
            case "-1":
                // Failed to create account, gettin error message
                self.stopSpinnerAndGetViewResponder()
                
                guard let errorMessage = response["errorMessage"] else {
                    // Can't get an error message.
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.alertToUserWithMesage(errorMessage, segueIdentifier: "fromSignUpVCtoLogInVC")
                
            default:break
            }
        }
    }
    
    // MARK: Spinner ActivityIndicator Configuration
    /**
     Start user interaction and stop Spinner animation.
     */
    private func stopSpinnerAndGetViewResponder() {
        UIApplication.shared.endIgnoringInteractionEvents()
        spinner.stopAnimating()
    }
    
    /**
     Start user interaction, stop Spinner animation and alert user with an error message and segue to LogInViewController
     */
    private func stopSpinnerAndAlertUser() {
        self.spinner.stopAnimating()
        if self.view.canBecomeFirstResponder {
            self.view.becomeFirstResponder()
        }
        self.alertToUserWithMesage("Uexpected error occured, please try again later.", segueIdentifier: "fromSignUpVCtoLogInVC")
    }
    
    /**
        Resign any subviews that is first responder and stop user interaction. Start spinner animation.
     */
    private func startSpinnerAndResignTheView() {
        let objects = [
            firstNameTextField,
            lastNameTextField,
            phoneNumberTextField,
            emailTextField,
            passwordTextField,
            confirmPasswordTextField,
            termsAndConditionsButton,
            signUpButton
        ]
        
        for object in objects {
            if (object?.isFirstResponder)! {
                object?.resignFirstResponder()
            }
        }
        
        spinner.startAnimating()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
    }
    
    /**
     Alert user with a message and segue to identified View Controller.
     - parameter message: of an alert.
     - parameter segueIdentifier: to perform segue with given SegueIdentifier.
     */
    private func alertToUserWithMesage(_ message: String, segueIdentifier: String) {
        let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        { action -> Void in
            if segueIdentifier != "" {
                self.performSegue(withIdentifier: segueIdentifier, sender: self)
            }
        })
        self.present(alertController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromSignUpVCtoLogInVC"{
            let destinationVC = segue.destination as? LogInViewController
            destinationVC?.performeAnimate = false
        }
        
        if segue.identifier == "fromSignUpVCtoTermsAndConditionsVC" {
            let destinationVC = segue.destination as? TermsAndConditionsViewController
            destinationVC?.newCustomer = self.newCostumer
        }
        
        if segue.identifier == "fromSignUpVCtoPrivacyPolicyVC" {
            let destinationVC = segue.destination as? PrivacyPolicyViewController
            destinationVC?.newCustomer = self.newCostumer
        }
    }
}

