//
//  GapzaAPI.swift
//  Gappza
//
//  Created by Firdavsii Majidzoda on 11/8/16.
//  Copyright © 2016 Gappza. All rights reserved.
//

import Alamofire
import UIKit

// MARK: Endpoint methods
enum Method: String {
    case validateEmail = "checkIfAccountExist.php"
    case validateActivation = "isAccountActivated.php"
    case validatePassword = "validatePassword.php"
    case createNewAccount = "createAccount.php"
    case getFirstName = "getFirstName.php"
    case forGotPassword = "forgtoPassword.php"
    case changePassword = "changePassword.php"
    case deleteAccount = "deleteAccount.php"
    case getTransactions = "getTransactions.php"
    case captureCharge = "captureCharge.php"
    case storePayment = "storePaymentToDB.php"
    case checkPaymentStatus = "checkPaymentStatus.php"
    case informBalance = "informBalance.php"
}

struct GapzaAPI {
    // Base web server url string
    private static let baseURLString = "http://ec2-54-224-149-158.compute-1.amazonaws.com/"
    
    /**
        Complete link, combines base url link and endpoint method.
        - parameter method: -endpoint method
        - returns: complete url -string
     */
    static func appnameURL(method: Method) -> String {
        let completeURL: String = baseURLString+method.rawValue
        return completeURL
    }
    
    
    // MARK: Gapza API calls
    /**
        Valides email if it exist in Data Base.
         - parameter email: for account to be validated.
         - parameter completion: return JSON result on completion
     */
    static func validateEmail(email: String, completion: @escaping ([String:String]) -> Void) {
        var result:[String:String] = [:]
        
        
        let parameters: Parameters = ["email": email.lowercased()]
        Alamofire.request(appnameURL(method: .validateEmail), method: .post, parameters: parameters).responseJSON{
            (response) -> Void in
            
            // Checking if we have a successful result
            guard response.result.isSuccess else {
                // Unsuccessful query
                result["status"] = "0"
                result["errorMessage"] = "Unexpected error ocured, please try again later."
                completion(result)
                return
            }
            
            do {
                if let jsonData = response.data{
                    // Parsing response to JSON
                    let jsonBody = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:AnyObject]
                    
                    // Getting response status
                    guard let status = jsonBody["status"] as? String else {
                        // Can't get a response status
                        result["status"] = "-1"
                        result["errorMessage"] = "Unexpected error ocured, please try again later."
                        completion(result)
                        return
                    }
                    
                    if status == "1" {
                        // Success for SignUpViewController
                        // Failure for LogInViewController
                        
                        result["status"] = status
                        // Can't get a message
                        guard let errorMessage = jsonBody["message"] as? String else {
                            // Can't get a message
                            result["status"] = "-1"
                            result["message"] = "Unexpected error ocured, please try again later."
                            completion(result)
                            return
                        }
                        result["message"] = errorMessage
                    } else {
                        // Failure for SignUpViewController
                        // Success for LogInViewController
                        guard let message = jsonBody["message"] as? String else {
                            // Can't get a message
                            result["status"] = "-1"
                            result["message"] = "Unexpected error ocured, please try again later."
                            completion(result)
                            return
                        }
                        
                        result["status"] = status
                        result["message"] = message
                    }
                }
            } catch {
                // Can't parse response to JSON
                result["message"] = "Unexpected error ocured, please try again later."
            }
            completion(result)
        }
    }
    
    /**
        Delete Account with all it's transactions
        - parameter email: associated email for an account to be deleted
        - parameter completion: return JSON result on completion
     */
    static func deleteAccount(email: String, completion: @escaping ([String:String]) -> Void){
        print("GapzaAPI "+#function)
        var result:[String:String] = [:]
        
        let parameter: Parameters = ["email": email]
        Alamofire.request(appnameURL(method: .deleteAccount), method: .post, parameters: parameter).responseJSON{
            response in
            
            // Checking if we have a successful result
            guard response.result.isSuccess else {
                // Unsuccessful query
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error ocured, please try again later."
                completion(result)
                return
            }
            
            do {
                if let jsonData = response.data{
                    // Parsing response to JSON
                    let jsonBody = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:AnyObject]
                    
                    // Getting response status
                    guard let status = jsonBody["status"] as? String else {
                        // Can't get a response status
                        result["status"] = "-1"
                        result["errorMessage"] = "Unexpected error ocured, please try again later."
                        completion(result)
                        return
                    }
                    
                    if status == "1" {
                        // Success
                        
                        guard let message = jsonBody["message"] as? String else {
                            // Can't get a message
                            result["status"] = "-1"
                            result["message"] = "Unexpected error ocured, please try again later."
                            completion(result)
                            return
                        }
                        result["status"] = status
                        result["message"] = message
                    } else {
                        
                        // Failure
                        guard let errorMessage = jsonBody["errorMessage"] as? String else {
                            // Can't get a message
                            result["status"] = "-1"
                            result["message"] = "Unexpected error ocured, please try again later."
                            completion(result)
                            return
                        }
                        
                        result["status"] = status
                        result["errorMessage"] = errorMessage
                    }
                }
            } catch {
                // Can't parse response to JSON
                result["message"] = "Unexpected error ocured, please try again later."
            }
            completion(result)
        }
    }
    
    /**
        Generate temproralily encrypted password and inform user through email.
         - parameter email: for an accaunt a password to be generated
         - parameter hasPass: encrypted password
         - parameter tempPass: npt encrypted password
         - parameter firstName: User's first name for greeting in email text
         - parameter completion: return JSON result on completion
     */
    static func forGotPassword(email: String, hashPass: String, tempPass: String, firstName: String, completion: @escaping ([String:String]) -> Void){
        print("GapzaAPI "+#function+"(function)")
        var result:[String:String] = [:]
        
        Alamofire.request(appnameURL(method: .forGotPassword), method: .post, parameters: ["email": email, "hashPassword": hashPass, "tempPass": tempPass, "firstName": firstName]).responseJSON{
            response in
            
            // Checking if we have a successful result
            guard response.result.isSuccess else{
                // result is unsuccessful
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error ocured, please try again later."
                completion(result)
                return
            }
            
            do {
                if let jsonData = response.data{
                    // Getting JSON
                    let jsonBody = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:AnyObject]
                    
                    // Geting status
                    guard let status = jsonBody["status"] as? String else {
                        // Can't get status
                        result["status"] = "-1"
                        result["errorMessage"] = "Unexpected error ocured, contact info.gapza@gmail.com"
                        completion(result)
                        return
                    }
                    
                    if status == "1" {
                        // Success, getting response message
                        guard let message = jsonBody["message"] as? String else {
                            // Can't get a message
                            result["message"] = ""
                            result["status"] = status
                            completion(result)
                            return
                        }
                        result["status"] = status
                        result["message"] = message
                    } else {
                        // Failure, getting error message
                        guard let errorMessage = jsonBody["errorMessage"] as? String else {
                            // Can't get error message
                            result["status"] = "-1"
                            result["errorMessage"] = "Unexpected error ocured, please try again later."
                            completion(result)
                            return
                        }
                        result["status"] = status
                        result["errorMessage"] = errorMessage
                    }
                }
            } catch {
                // Can't parse to JSON
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error ocured, please try again later."
                completion(result)
            }
            
            completion(result)
        }
    }
    
    /**
        Activates registered account in Data Base
         - parameter email: associated wit accaunt to be activated
         - parameter completion: return JSON result on completion
     */
    static func validateActivation(email: String, completion: @escaping ([String:String]) -> Void){
        var result:[String:String] = [:]
        Alamofire.request(appnameURL(method: .validateActivation), method: .post, parameters: ["email": email]).responseJSON{
            (response) -> Void in
            
            // Checking if we have a successful result
            guard response.result.isSuccess else {
                // Unsuccessful query
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error occured, pleae try again later."
                completion(result)
                return
            }
            
            do {
                if let jsonData = response.data{
                    // Parsing response to JSON
                    let jsonBody = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:AnyObject]
                    
                    // Getting response status
                    guard let status = jsonBody["status"] as? String else {
                        // Can't get a response status
                        result["status"] = "-1"
                        result["errorMessage"] = "Unexpected error ocured, please try again later."
                        completion(result)
                        return
                    }
                    
                    if status == "1" {
                        // Success
                        result["status"] = status
                    } else {
                        // Failure, getting error message
                        guard let errorMessage = jsonBody["errorMessage"] as? String else {
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
                result["errorMessage"] = "Unexpected error occured, please try again later."
            }
            completion(result)
        }
    }
    
    /**
        Checks for corret password in Data Base
         - parameter params: details for an account password to be validated
         - parameter completion: return JSON result on completion
     */
    static func validatePassword(_ params:[String:String], completion: @escaping ([String:String]) -> Void) {
        
        Alamofire.request(appnameURL(method: .validatePassword), method: .post, parameters: params).responseJSON{
            (response) -> Void in
            
            var result:[String:String] = [:]
            
            // Checking if we have a successful result
            guard response.result.isSuccess else {
                // Unsuccessful query
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error ocured, contact info.gapza@gmail.com"
                completion(result)
                return
            }
            
            do {
                if let jsonData = response.data{
                    // Parsing response to JSON
                    let jsonBody = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:AnyObject]
                    
                    // Getting response status
                    guard let status = jsonBody["status"] as? String else {
                        // Can't get a response status
                        result["status"] = "-1"
                        result["errorMessage"] = "Unexpected error occured, please try again later."
                        completion(result)
                        return
                    }
                    
                    if status == "1" {
                        // Success
                        result["status"] = status
                        
                    } else {
                        // Failure, getting error message
                        guard let errorMessage = jsonBody["errorMessage"] as? String else {
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
            } catch {
                // Can't parse response to JSON
                result["message"] = "Unexpected error occured, please try again later."
            }
            completion(result)
        }
    }
    
    /**
        Create an account with given customer details in Data Base
         - parameter params: details for an accaunt to be creared.
         - parameter completion: return JSON result on completion
     */
    static func createNewAccount(_ params: [String:String], completion: @escaping ([String:String]) -> Void){
        
        Alamofire.request(appnameURL(method: .createNewAccount), method: .post, parameters: params).responseJSON{
            (response) -> Void in
            var result:[String:String] = [:]
            
            // Checking if we have a successful result
            guard response.result.isSuccess else {
                // Unsuccessful query
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error ocured, please try again later."
                completion(result)
                return
            }
            
            do {
                if let jsonData = response.data{
                    // Parsing response to JSON
                    let jsonBody = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:AnyObject]
                    
                    // Getting response status
                    guard let status = jsonBody["status"] as? String else {
                        // Can't get a response status
                        result["status"] = "-1"
                        result["errorMessage"] = "Unexpected error ocured, please try again later."
                        completion(result)
                        return
                    }
                    
                    if status == "1" {
                        // Success, getting message
                        guard let message = jsonBody["message"] as? String else {
                            // Can't get a message
                            result["status"] = "-1"
                            result["errorMessage"] = "Unexpected error ocured, please try again later."
                            completion(result)
                            return
                        }
                        result["status"] = status
                        result["message"] = message
                    } else {
                        // Failure, getting error message
                        guard let errorMessage = jsonBody["errorMessage"] as? String else {
                            // Can't get an error message
                            result["status"] = "-1"
                            result["errorMessage"] = "Unexpected error ocured, please try again later."
                            completion(result)
                            return
                        }
                        result["status"] = status
                        result["errorMessage"] = errorMessage
                    }
                }
            } catch {
                // Can't parse repsonse to JSON
                result["status"] = "-1"
                result["message"] = "Unexpected error ocured, please try again later."
            }
            completion(result)
        }
    }
    
    /**
        Change Password for user with given email
         - parameter params: details for an account's password to be changed
         - parameter completion: return JSON result on completion
     */
    static func changePassword(_ params: [String:String], completion: @escaping ([String:String]) -> Void){
        print("GapzaAPI "+#function+"(function)")
        Alamofire.request(appnameURL(method: .changePassword), method: .post, parameters: params).responseJSON{
            (response) -> Void in
            
            var result:[String:String] = [:]
            
            // Checking if we have a successful result
            guard response.result.isSuccess else {
                // Unsuccessful query
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error occured please try again later."
                completion(result)
                return
            }
            
            do {
                if let jsonData = response.data{
                    // Parsing response to JSON
                    let jsonBody = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:AnyObject]
                    
                    // Getting response status
                    guard let status = jsonBody["status"] as? String else {
                        // Can't get a response status
                        result["status"] = "-1"
                        result["errorMessage"] = "Unexpected error occured, please try again later."
                        completion(result)
                        return
                    }
                    
                    if status == "1" {
                        // Success, password updated
                        guard let firstName = jsonBody["message"] as? String else {
                            // Can't get a message
                            result["status"] = "-1"
                            result["errorMessage"] = "Unexpected error occured please try again later."
                            completion(result)
                            return
                        }
                        result["status"] = status
                        result["message"] = firstName
                        
                    } else {
                        // Failure, getting error message
                        guard let errorMessage = jsonBody["errorMessage"] as? String else {
                            // Can't get error message
                            result["status"] = "-1"
                            result["errorMessage"] = "Unexpected error occured please try again later."
                            completion(result)
                            return
                        }
                        result["status"] = status
                        result["errorMessage"] = errorMessage
                    }
                }
            } catch {
                // Can't parse response to JSON
                result["status"] = "-1"
                result["message"] = "Unexpected error ocured, please try again later."
            }
            completion(result)
            
        }
    }
    
    /**
        Gets user first name with given email.
        - parameter params: details for an account's first name to be fetched.
        - parameter completion: return JSON result on completion
     */
    static func getUsersFirstName(_ params: [String:String], completion: @escaping ([String:String]) -> Void){
        
        Alamofire.request(appnameURL(method: .getFirstName), method: .post, parameters: params).responseJSON{
            (response) -> Void in
            var result:[String:String] = [:]
            
            // Checking if we have a successful result
            guard response.result.isSuccess else {
                // Unsuccessful query
                result["status"] = "-1"
                result["errorMessage"] = "Unexpected error occured please try again later."
                completion(result)
                return
            }
            
            do {
                if let jsonData = response.data{
                    // Parsing response to JSON
                    let jsonBody = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:AnyObject]
                    
                    // Getting response status
                    guard let status = jsonBody["status"] as? String else {
                        // Can't get a response status
                        result["status"] = "-1"
                        result["errorMessage"] = "Unexpected error occured, please try again later."
                        completion(result)
                        return
                    }
                    
                    if status == "1" {
                        // Success, getting first name
                        guard let firstName = jsonBody["message"] as? String else {
                            // Can;t get first name
                            result["status"] = "-1"
                            result["errorMessage"] = "Unexpected error occured please try again later."
                            completion(result)
                            return
                        }
                        result["status"] = status
                        result["message"] = firstName
                        
                    } else {
                        // Failure, getting error message
                        guard let errorMessage = jsonBody["errorMessage"] as? String else {
                            // Can't get error message
                            result["status"] = "-1"
                            result["errorMessage"] = "Unexpected error occured please try again later."
                            completion(result)
                            return
                        }
                        result["status"] = status
                        result["errorMessage"] = errorMessage
                    }
                }
            } catch {
                // Can't parse response to JSON
                result["status"] = "-1"
                result["message"] = "Unexpected error ocured, please try again later."
            }
            completion(result)
        }
    }
}


