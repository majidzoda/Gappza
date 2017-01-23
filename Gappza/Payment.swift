//
//  Payment.swift
//  Gappza
//
//  Created by Firdavsii Majidzoda on 10/14/16.
//  Copyright © 2016 Biki. All rights reserved.
//

import Alamofire
import SwiftyXMLParser
import Stripe

struct Payment {
    
    // MARK: Fields
    let providers = [
        "Intercom NGN": "42",
        "Eastera NGN": "43",
        "Babilon NGN": "44",
        "TelecomTech NGN": "48",
        "Megafon": "90",
        "Beeline": "91",
        "Tcell": "93",
        "TKmobile": "95",
        "Babilon-M": "98",
    ]
    
    private let providersPrefix = [
        "Intercom NGN": "4",
        "Eastera NGN": "4",
        "Babilon NGN": "4",
        "TelecomTech NGN": "4",
        "Megafon": "9",
        "Beeline": "9",
        "Tcell": "9",
        "TKmobile": "9",
        "Babilon-M": "9",
        ]
    
    let providersFormat = [
        "Intercom NGN": "Sample: 4X XXX XXXX",
        "Eastera NGN": "Sample: 4X XXX XXXX",
        "Babilon NGN": "Sample: 4X XXX XXXX",
        "TelecomTech NGN": "Sample: 4X XXX XXXX",
        "Megafon": "Sample: 9X XXX XXXX",
        "Beeline": "Sample: 9X XXX XXXX",
        "Tcell": "Sample: 9X XXX XXXX",
        "TKmobile": "Sample: 9X XXX XXXX",
        "Babilon-M": "Sample: 9X XXX XXXX",
    ]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // MARK: Emon attributes
    private let un = "firdavsusaxml"
    private let pass = "52819380975"
    private let secretKey = "WS#!@aq54&*kgj"
    var emonPaymentId: String?
    
    
    // MARK: Gapza attributes
    var userEmail: String?
    var number: String?
    var providerID: String?
    var providerError: String?
    var amount: String?
    var isTermsAndConditionChecked: Bool?
    var exchRate: Double?
    var numberLength: Int?
    var paymentID: String?         //For Gapza Side
    var description = "Payment"
    var date: String?
    var providerName: String?
    var fullAmount: String?
    
    
    // MARK: Stripe attributes
    var stripeToken:String?
    var paymentTextField: STPPaymentCardTextField!
    var capturedChargedID: String?
    var appFee: String?
    
    // MARK: Initialization
    init(){
        let user = User()
        userEmail = user.loadCurrentUserEmail()
        number = ""
        providerID = "42"
        providerError = providersFormat["Intercom NGN"]
        amount = ""
        exchRate = 7.8
        numberLength = 9
        paymentID = ""
        
        stripeToken = ""
        capturedChargedID = ""
        appFee = ""
        
        let nsDate = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day,.month,.year], from: nsDate)
        date = (components.day?.description)!+"-"+(components.month?.description)!+"-"+(components.year?.description)!
        date = dateFormatter.string(from: nsDate)
        isTermsAndConditionChecked = false
        providerName = "Intercom NGN"
    }
    
    
    // MARK: API calls
    
    /**
        Get token from Stripe, return JSON result on comletiion.
        - parameter paymentTextField: card to be charged
        - parameter completion: return JSON when done
     */
    func getToken(_ paymentTextField:STPPaymentCardTextField, completion:@escaping ([String: String]) -> Void){
        var result:[String:String] = [:]
        
        let card = paymentTextField.cardParams
        
        STPAPIClient.shared().createToken(withCard: card){
            token, error in
            
            // Getting token from data
            guard let stripeToken = token else {
                NSLog("Error creating token: %@", error!.localizedDescription);
                result["status"] = "-1"
                result["errorMessage"] = "Your card is not going through, try different card."
                completion(result)
                return
            }
            
            // Success, got token
            result["status"] = "1"
            result["token"] = stripeToken.tokenId

            
            completion(result)
        }
    }
    
    
    
    /**
        Capture charge from Stripe, return JSON result on completion.
        - parameter completion: return JSON when done
     */
    mutating func captureCharge (_ completion: @escaping ([String: String]) -> Void){
        var result: [String: String] = [:]
        
        // Setting uniqie id
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.second,.nanosecond], from: date)
        let id = (components.second?.description)!+(components.nanosecond?.description)!
        
        
        let finalAmount = Double(amount!)!+2.0+Double(appFee!)!
        let am = finalAmount.description
        
        let tok = stripeToken!
        
        let params = [
            "stripeToken": tok,
            "amount": am,
            "currency": "usd",
            "description": id
        ]
        
        
        Alamofire.request(GapzaAPI.appnameURL(method: .captureCharge), method: .post, parameters: params).responseJSON{
            response in
            
            // Checking if we have a successful result
            guard response.result.isSuccess else {
                // Unsuccessful connection to api
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error occured, please try again later"
                completion(result)
                return
            }
            
            do {
                if let jsonData = response.data{
                    // Parsing response to JSON
                    let jsonBody = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject]
                    // Getting response status
                    guard let status = jsonBody?["status"] as? String else {
                        // Can't get status response
                        result["status"] = "-1"
                        result["errorMessage"] = "Unexpected error occured, please try again later."
                        completion(result)
                        return
                    }
                    
                    if status == "1" {
                        // Success, getting captured charge id
                        let capturedID = jsonBody?["capturedID"] as? String
                        
                        // Can't get an id
                        result["status"] = status
                        result["capturedID"] = capturedID!
                        result["paymentID"] = id
                        
                    } else {
                        // Failure, card problem, getting error message
                        guard let errorMessage = jsonBody?["errorMessage"] as? String else {
                            
                            // Can't get an error message
                            result["status"] = "-1"
                            result["errorMessage"] = "Unexpected error occured, please try again later."
                            completion(result)
                            return
                        }
                        result["status"] = status
                        result["errorMessage"] = errorMessage
                    }
                }
            } catch{
                // Can't parse response to JSON
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error occured, please try again later."
                completion(result)
            }
            completion(result)
        }
    }
    
    
    /**
        Prepare for payment, get exhchange rate, set payment exchange rate. return JSON result on completion.
         - parameter completion: return JSON when done
     */
    func prepareForPayment(_ completion: @escaping ([String: AnyObject]) -> Void){
        //6a07a1f046e77670f78d4bf96c6497fb
        
        Alamofire.request("http://www.apilayer.net/api/live?access_key=6a07a1f046e77670f78d4bf96c6497fb&currencies=TJS&format=1").responseJSON{
            (response) -> Void in
            
            
            var result:[String:AnyObject] = [:]
            
            // Checking if for successful connection
            guard response.result.isSuccess else {
                // Can't connect to server
                result["status"] = "-1" as AnyObject?
                result["errorMessage"] = "Unexpected error occured, please try again later." as AnyObject?
                return
            }
            
            do {
                if let jsonData = response.data{
                    // Parsing data to JSON
                    let jsonBody = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:AnyObject]
                    
                    // Gettig values from JSON
                    guard let quotes = jsonBody?["quotes"] as? [String : AnyObject],
                        let USDTJS = quotes["USDTJS"] as? Double else {
                            // Can't get rate, format might been changed
                            result["status"] = "-1" as AnyObject?
                            result["errorMessage"] = "Unexpected error occured, please try again later." as AnyObject?
                            completion(result)
                            return
                    }
                    result["status"] = "1" as AnyObject?
                    result["rate"] = USDTJS as AnyObject?
                }
            } catch {
                // Can't parse data to JSON
                result["status"] = "-1" as AnyObject?
                result["error"] = "Unexpected error occured, please try again later." as AnyObject?
                completion(result)
            }
            completion(result)
        }
        
    }
    
    
    // MARK: Emon API calls
    
    /**
        Make a payment for Emon.
         - parameter completion: return JSON when done
     */
    func makePayment(_ completion: @escaping ([String: String]) -> Void){
        
        let calc = Double(amount!)!*exchRate!
        
        let psm = NSString(format: "%.2f", calc)
        
        
        let opid = providerID!
        let nm = number!
        
        let txd = paymentID!
        
        let keyBase = "\(un)\(opid)\(txd)\(psm)\(nm)\(pass.md5())\(secretKey)"
        let key = keyBase.sha1()
        
        // Make a payment
        let link = "http://emon.tj/xml2/pay.aspx?un=\(un)&psm=\(psm)&opid=\(opid)&nm=\(nm)&txd=\(txd)&reg=&key=\(key)"
        
        Alamofire.request(link, method: .post).responseData{
            response in
            
            
            var result: [String:String] = [:]
            // Checking for a successful connection to server
            guard response.result.isSuccess else {
                // Failed to connect
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error occured, please try again later."
                completion(result)
                return
            }
            
            // Getting response data
            guard let data = response.data else {
                // Can't get response data
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error occured, please try again later."
                completion(result)
                return
            }
            
            // Sample response: <?xml version="1.0" encoding="UTF-8"?><payment><PaymentID>52273924</PaymentID><Status>1</Status><Comment>Пардохт кайд шуд</Comment></payment>
            
            // Parsing data to XML
            let xml = XML.parse(data)
            
            // Getting status
            guard let status = xml["payment", "Status"].text else {
                // Cant't get status
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error occured, please try again later."
                completion(result)
                return
            }
            
            // Getting emon payment id from XML
            guard let emonPaymentId = xml["payment", "PaymentID"].text else {
                // Failed to get Emon Payment Id
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error occured, please try again later."
                completion(result)
                return
            }
            self.checkBalance()
            result["emonPaymentID"] = emonPaymentId
            result["status"] = status
            completion(result)
        }
    }
    
    /**
        Post a payment in Data Base, and check payment status and inform user through email.
     */
    func postPayment() {
        let am = Int(amount!)!
        let id = emonPaymentId!
        let keyBase = "\(un)\(pass.md5())\(secretKey)\(id)"
        let key = keyBase.sha1()
        let link = "http://emon.tj/xml2/check.aspx?un=\(un)&PaymentID=\(id)&key=\(key)"
        
        let paramsForStoreDB: [String:String] = [
            "email": userEmail!,
            "number": number!,
            "amount": am.description,
            "paymentId": paymentID!,
            "emonPaymentId":emonPaymentId!,
            "date": date!
        ]
        
        Alamofire.request(GapzaAPI.appnameURL(method: .storePayment), method: .post, parameters: paramsForStoreDB).responseString{
            response in
        }
        
        let user = User()
        let finalAmount = Double(amount!)!+2.0+Double(appFee!)!
        let paramsForCheckPayment: [String:String] = [
            "firstName": user.loadCurrentUserFirstName(),
            "email": userEmail!,
            "number": number!,
            "amount": finalAmount.description,
            "emonPaymentId":emonPaymentId!,
            "paymentId": paymentID!,
            "capturedChargeId": capturedChargedID!,
            "statusCheckLink": link,
            "date": date!
        ]
        
        Alamofire.request(GapzaAPI.appnameURL(method: .checkPaymentStatus), method: .post, parameters: paramsForCheckPayment).responseString{
            response in
        }
    }
    
    /**
        Check balance and infrom if it is less then $200.
     */
    func checkBalance (){
        let balanceCheck = "http://emon.tj/xml2/balance.aspx?un=firdavsusaxml&key=b2902ca4d43835a3b8792507d08bf98e7f50ad02"
        
        Alamofire.request(balanceCheck).responseData {
            response in
            
            // Checking for successful connection.
            guard response.result.isSuccess else {
                // Failure
                return
            }
            
            // Getting data from response
            guard let data = response.data else {
                // Cna't get the data
                return
            }
            
            // Parsing data to XML
            let xml = XML.parse(data)
            
            guard let result = xml["Answ", "Balance"].text else {
                // Failed to get value out of XML
                return
            }
            
            // Converting to $
            let bal = Double(result)!/self.exchRate!
            
            // Warning about less balance
            if  bal < 200.0{
                Alamofire.request(GapzaAPI.appnameURL(method: .informBalance), method: .post, parameters: ["balance": bal]).responseString{
                    response in
                }
            }
        }
    }
    
    // MARK: Validating STPCardField
    /**
        Validate Card with details.
         - returns: "" if valid, error message otherwise
     */
    func validateSTPCardField() -> String {
        if paymentTextField!.isValid {
            return ""
        }
        return "Invalid Credit card."
    }
    
    // MARK: Validate phone number.
    /**
        Validae phone number:
         - Cannot be empty
         - Has to match with identified length
         - Only numbers allowed
         - returns: "" if valid, error message otherwise
     */
    func validateNumber() -> String {
        if number == "" {
            return "Your phone number cannot be empty."
        } else {
            if doStringContainsNumber(number: number!) == true {
                if (number?.characters.count)! < numberLength! ||  number!.characters.count > numberLength!{
                    return providerError!
                } else if number!.hasPrefix(providersPrefix[providerName!]!){
                    return ""
                } else {
                    return providerError!
                }
            } else {
                return "Only numbers allowed."
            }
        }
    }
    
    // MARK: Validate amount
    /**
        Validate amount.
         - Can not be empty
         - Should be between 5 - 20
         - Only number allowed
         - returns: "" if valid, error message otherwise
     */
    func validateAmmount() -> String {
        if amount == "" {
            return "Amount can not be empty."
        } else {
            if doStringContainsNumber(number: amount!) == true {
                if Double(amount!)! > 20.0  || Double(amount!)! < 5.0 {
                    return "Amount should be between 5 - 20."
                } else {
                    return ""
                }
            } else {
                return "Only numbers allowed."
            }
        }
    }
    
    /**
     Check if string only contain numbers.
     - parameter number: string about to be checked
     - returns: true or false
     */
    fileprivate func doStringContainsNumber(number : String) -> Bool{
        
        
        let badCharacters = CharacterSet.decimalDigits.inverted
        
        if number.rangeOfCharacter(from: badCharacters) == nil {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Validate Terms and Conditions Button
    /**
        Validate Terms and Conditions, isChecked.
         - returns: "" if valid, error message otherwise
     */
    func validateTermsButton() -> String {
        if (isTermsAndConditionChecked!){
            return ""
        } else {
            return "Agree to terms and conditions"
        }
    }
    
    // MARK: Validate Payment
    /**
        Validate Payment:
         - validateNumber() should return ""
         - validateAmmount() should return ""
         - validateSTPCardField() should return ""
         - validateTermsButton() should return ""
         - returns: "" if valid, error message otherwise
     */
    func validatePayment() -> String {
        return ""+validateNumber()+validateAmmount()+validateSTPCardField()+validateTermsButton()
    }
    
    
    // MARK: Calculate fee
    /**
        Calculate app fee
         - returns: .00 formatted -string
     */
    mutating func calcFee()-> String{
        let amountEntered = Double(amount!)
        let gapzaFee = 2.0
        let stripeFee = (amountEntered!+gapzaFee)*3.0/100+0.31
        let stripeFeeFormatted = NSString(format: "%.2F", stripeFee)
        return stripeFeeFormatted as String
    }
}

