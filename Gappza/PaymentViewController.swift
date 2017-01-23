//
//  PaymentViewController.swift
//  Gappza
//
//  Created by Firdavsii Majidzoda on 10/14/16.
//  Copyright © 2016 Biki. All rights reserved.
//

import Stripe
import UIKit

class PaymentViewController: UIViewController, STPPaymentCardTextFieldDelegate, UIPickerViewDataSource,UIPickerViewDelegate, UITextFieldDelegate {
    
    // MARK: outlets
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var providerPicker: UIPickerView!
    
    @IBOutlet var numberErrorTextField: UILabel!
    @IBOutlet var numberTextField: UITextField!
    
    @IBOutlet var ammountErrorLabel: UILabel!
    @IBOutlet var ammountTextField: UITextField!
    
    @IBOutlet var termsTextView: UITextView!
    
    @IBOutlet var appFeeTextLabel: UILabel!
    
    @IBOutlet var termsAndConditionsTextView: UITextView!
    
    @IBOutlet var termsConditionButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var cardPaymentViewHolder: UIView!
    
    @IBOutlet var cardPaymentWidh: NSLayoutConstraint!
    
    
    // MARK: Fields
    private var paymentTextField: STPPaymentCardTextField!
    private var payment = Payment()
    private var activeField: UITextField?
    
    private var logOutTimeSet: Date!
    private var logOutMessage: String!
    
    private let providers = [
        "Intercom NGN",
        "Eastera NGN",
        "Babilon NGN",
        "TelecomTech NGN",
        "Megafon",
        "Beeline",
        "Tcell",
        "TKmobile",
        "Babilon-M"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        
        // Adding observers
        registerForEnterBackForGroundsObservers()
        registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    // MARK: Prepare For View
    /**
     Prepares and configures subviews.
     */
    func prepareView() {
        paymentTextFieldConfiguration()
        
        setDelegations()
        
        termsViewConfiguration()
        
        submitButtonConfiguration()
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
            performSegue(withIdentifier: "fromPaymentVCtoLogInVC", sender: self)
        }
    }
    
    // MARK: Keyboard moves scroll view Configuration
    /**
     Add observesr anytime keyboard appears with following selectors:
     - keyboardWasShown()
     - keyboardWillBeHidden()
     */
    private func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /**
     Removes keyboard observer
     */
    func deregisterFromKeyboardNotifications(){
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
    
    
    // MARK: paymentTextField STPPaymentCardTextField Configuration
    /**
        Create STPPaymentCardTextField and add to cardPaymentViewHolder view.
     */
    private func paymentTextFieldConfiguration(){
        paymentTextField = STPPaymentCardTextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.width-40, height: 44))
        paymentTextField.delegate = self
        
        payment.paymentTextField = self.paymentTextField
        cardPaymentViewHolder.addSubview(paymentTextField)
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if paymentTextField.isValid{
            paymentTextField.resignFirstResponder()
        }
        updateSubmitButtonStatus()
    }
    
    
    // MARK: providerPicker UIPickerView Configuration
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return providers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return providers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        payment.providerID = payment.providers[providers[row]]
        payment.providerError = payment.providersFormat[providers[row]]
        payment.providerName = providers[row]
        if numberTextField.hasText && numberTextField.text != "" {
            numberErrorTextField.text = payment.validateNumber()
        }
        updateSubmitButtonStatus()
    }
    
    
    // MARK: Number TextField Configuration
    /**
     Set payment number and updates numberErrorTextField error and validates Submit Button when TextField's text change begin.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func numberTextFieldDidbegin(_ sender: UITextField) {
        payment.number = numberTextField.text!
        numberErrorTextField.text = payment.validateNumber()
        updateSubmitButtonStatus()
        activeField = sender
        
    }
    
    /**
     Set payment number and updates numberErrorTextField error and validates Submit Button when TextField's text change.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func numberTextFieldDidChange(_ sender: UITextField){
        payment.number = numberTextField.text!
        numberErrorTextField.text = payment.validateNumber()
        updateSubmitButtonStatus()
        activeField = sender
    }
    
    /**
     Set payment number and updates numberErrorTextField error and validates Submit Button when TextField's text change ended.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func numberTextFieldDidEnd(_ sender: UITextField) {
        payment.number = numberTextField.text!
        numberErrorTextField.text = payment.validateNumber()
        updateSubmitButtonStatus()
        activeField = sender
    }
    
    
    // MARK: Amount TextField Configuration
    /**
     Set payment amount and updates ammountErrorLabel error and validates Submit Button when TextField's text change begin.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func ammountTextFieldDidBegin(_ sender: UITextField) {
        payment.amount = ammountTextField.text!
        ammountErrorLabel.text = payment.validateAmmount()
        updateSubmitButtonStatus()
        appFeeCalc()
        activeField = sender
    }
    
    /**
     Set payment amount and updates ammountErrorLabel error and validates Submit Button when TextField's text change.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func ammountTextFieldDidChange(_ sender: UITextField) {
        payment.amount = ammountTextField.text!
        ammountErrorLabel.text = payment.validateAmmount()
        updateSubmitButtonStatus()
        appFeeCalc()
        activeField = sender
    }
    
    /**
     Set payment amount and updates ammountErrorLabel error and validates Submit Button when TextField's text change ended.
     - parameter sender: TextField to be indetified as active
     */
    @IBAction func ammountTextFieldDidEnd(_ sender: UITextField) {
        payment.amount = ammountTextField.text!
        ammountErrorLabel.text = payment.validateAmmount()
        updateSubmitButtonStatus()
        appFeeCalc()
        activeField = sender
    }
    
    
    // MARK: TextFields delegations Configurations
    /**
     Set delegations to self for following:
     - numberTextField
     - ammountTextField
     */
    private func setDelegations(){
        numberTextField.delegate = self
        ammountTextField.delegate = self
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
            numberTextField,
            ammountTextField,
            paymentTextField
        ]
        
        for object in objects {
            if (object?.isFirstResponder)! {
                object?.resignFirstResponder()
            }
        }
    }
    
    
    // MARK: App fee calculation
    /**
        Calculate Application fee and set payment appFee, update appFeeTextLabel text.
     */
    private func appFeeCalc() {
        if ammountTextField.hasText && ammountTextField.text != "" && ammountTextField.text != "0" {
            if payment.validateAmmount() == "" {
                payment.appFee = payment.calcFee()
                appFeeTextLabel.text = "Card transaction and application fee: +\(Double(payment.calcFee())!+2.0)"
            }
        } else {
            payment.appFee = ""
            appFeeTextLabel.text = ""
        }
        
    }
    
    // MARK: Terms and Conditions Scroll View Configuration
    /**
        Flash scroll view indicator at VC onCreate
     */
    private func termsViewConfiguration(){
        termsTextView.flashScrollIndicators()
        termsTextView.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    // MARK: Terms and condition CheckBox (Button) Configuration
    /**
     Switch termsAndConditionsCheckBox state when clicked:
     - isChecked (true <-> false)
     - Update CheckBox background picture.
     - Update Submit Button state
     */
    @IBAction func termsButton(_ sender: AnyObject) {
        if (payment.isTermsAndConditionChecked!) {
            payment.isTermsAndConditionChecked = false
            termsConditionButton.setImage(UIImage(named: "disable checkbox"), for: UIControlState())
            updateSubmitButtonStatus()
        } else {
            payment.isTermsAndConditionChecked = true
            termsConditionButton.setImage(UIImage(named: "checkbox"), for: UIControlState())
            updateSubmitButtonStatus()
        }
    }
    
    // MARK: Submit Button Configuration
    /**
        Set submitButton state enable = false, disable background pic
     */
    private func submitButtonConfiguration(){
        submitButton.isEnabled = false
        submitButton.setBackgroundImage(UIImage(named: "Disabled Button"), for: .normal)
    }
    /**
        Validate Payment, set Submit button state enabled and change background to enable pic
     */
    private func updateSubmitButtonStatus() {
        if payment.validatePayment() == "" {
            submitButton.isEnabled = true
            submitButton.setBackgroundImage(UIImage(named: "Button"), for: .normal)
        } else {
            submitButton.setBackgroundImage(UIImage(named: "Disabled Button"), for: .normal)
            submitButton.isEnabled = false
        }
    }
    
    
    // MARK: API calls
    /**
        Get stripe token.
        - Call captureCharge() if succeeded
        - Otherwise stops Spinner and alert user with a message.
     */
    @IBAction func submitCard(_ sender: AnyObject?) {
        startSpinnerAndResignTheView()
        payment.getToken(paymentTextField){
            response in
            
            // Getting response status
            guard let status = response["status"] else {
                // Can't get a response status
                self.stopSpinnerAndAlertUser()
                return
            }
            
            switch status{
                
            case "1":
                // Getting token
                guard let token = response["token"] else {
                    // Can;t get a token
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.payment.stripeToken = token
                self.captureCharge()
                
            case "-1":
                // Failure, getting error message
                guard let errorMessage = response["errorMessage"] else {
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.stopSpinnerAndGetViewResponder()
                self.alertToUserWithMesage(errorMessage, segueIdentifier: "fromPaymentVCtoLogInVC")
                
            default:break
            }
        }
    }
    
    /**
        Capture charge for Stripe.
        - Call prepareForPayment() if succeeded
        - Otherwise stops Spinner and alert user with a message.
     */
    private func captureCharge(){
        payment.captureCharge(){
            response in
            
            // Getting response status
            guard let status = response["status"] else {
                // Can't get a response status
                self.stopSpinnerAndAlertUser()
                return
            }
            
            switch status {
                
            case "1":
                // Success, captured charge, getting captured charge id
                guard let capturedID = response["capturedID"] else {
                    // Can't get an id
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.payment.capturedChargedID = capturedID
                
                // Getting id for Emon system
                guard let paymentID = response["paymentID"] else {
                    // Can't get and id for Emon System
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.payment.paymentID = paymentID
                self.prepareForPayment()
                
            case "-1":
                // Failure, card might be declined
                guard let errorMessage = response["errorMessage"] else {
                    // Can't get an error message
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
        Prepare for payment.
        - call makePayment() if succeeded
        - Otherwise stops Spinner and alert user with a message.
     */
    private func prepareForPayment() {
        payment.prepareForPayment(){
            response in
            
            // Checking if we have a successful result
            guard let status = response["status"] as? String else {
                // Can't get status response
                self.stopSpinnerAndAlertUser()
                return
            }
            
            switch status{
                
            case "1":
                // Success, getting exchange rate
                guard let rate = response["rate"] as? Double else {
                    // Can't get exchange rate
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.payment.exchRate = rate
                self.makePayment()
                
            case "-1":
                // Failure
                self.stopSpinnerAndAlertUser()
                // Can't proccess for payment
                
            default: break
            }
        }
    }
    
    /**
        Make a payment for Emon.
        - call postPayment() if suceeded
        - - Otherwise stops Spinner and alert user with a message.
     */
    private func makePayment() {
        payment.makePayment(){
            response in
            
            // Getting response status
            guard let status = response["status"] else {
                // Can't get response status
                self.stopSpinnerAndAlertUser()
                return
            }
            
            switch status{
                
            case "1":
                // Succes, payment has been recieved
                guard let emonPaymentId = response["emonPaymentID"] else {
                    // Can't get emon payment ID
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.payment.emonPaymentId = emonPaymentId
                
                // Posting payment
                self.payment.postPayment()
                self.stopSpinnerAndGetViewResponder()
                self.alertToUserWithMesage("Your payment has been recieved. We will email you a reciepe for this transaction", segueIdentifier: "fromPaymentVCtoBarController")
                
            case "2":
                // Payment is complete
                guard let emonPaymentId = response["emonPaymentID"] else {
                    // Can't get emon payment ID
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.payment.emonPaymentId = emonPaymentId
                self.payment.postPayment()
                self.stopSpinnerAndGetViewResponder()
                self.alertToUserWithMesage("Your payment has been recieved. We will email you a reciepe for this transaction", segueIdentifier: "fromPaymentVCtoBarController")
                
            case "3":
                // Invalid phone number
                guard let emonPaymentId = response["emonPaymentID"] else {
                    // Can't get emon payment ID
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.payment.emonPaymentId = emonPaymentId
                self.payment.postPayment()
                self.stopSpinnerAndGetViewResponder()
                self.alertToUserWithMesage("Invalid number", segueIdentifier: "fromPaymentVCtoBarController")
            case "4":
                // Insufficient balance
                guard let emonPaymentId = response["emonPaymentID"] else {
                    // Can't get emon payment ID
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.payment.emonPaymentId = emonPaymentId
                self.payment.postPayment()
                self.stopSpinnerAndGetViewResponder()
                self.alertToUserWithMesage("Unexpected error occured, please try again later.", segueIdentifier: "fromPaymentVCtoBarController")
                
            case "-5":
                // Error in emon server
                guard let emonPaymentId = response["emonPaymentID"] else {
                    // Can't get emon payment ID
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.payment.emonPaymentId = emonPaymentId
                self.payment.postPayment()
                self.stopSpinnerAndGetViewResponder()
                self.alertToUserWithMesage("Unexpected error occured, please try again later.", segueIdentifier: "fromPaymentVCtoBarController")
                
            case "-1":
                // Invalid user name or hash code for Emon
                guard let emonPaymentId = response["emonPaymentID"] else {
                    // Can't get emon payment ID
                    self.stopSpinnerAndAlertUser()
                    return
                }
                self.payment.emonPaymentId = emonPaymentId
                self.payment.postPayment()
                self.stopSpinnerAndGetViewResponder()
                self.alertToUserWithMesage("Unexpected error occured. please try again later", segueIdentifier: "fromPaymentVCtoBarController")
                
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
            numberTextField,
            ammountTextField,
            paymentTextField,
            providerPicker
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
        self.alertToUserWithMesage("Uexpected error occured, please try again later.", segueIdentifier: "fromPaymentVCtoLogInVC")
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
        if segue.identifier == "fromPaymentVCtoLogInVC"{
            let destinationVC = segue.destination as? LogInViewController
            if logOutMessage == "We logged you out for security purposes."{
                destinationVC?.logOutMessage = "We logged you out for security purposes."
            }
            destinationVC?.performeAnimate = false
        }
    }
    
}

