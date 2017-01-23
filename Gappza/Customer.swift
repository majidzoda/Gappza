//
//  Customer.swift
//  Gapzpa
//
//  Created by Firdavsii Majidzoda on 11/8/16.
//  Copyright © 2016 Gappza. All rights reserved.
//


import UIKit

class Customer {
    
    // MARK: Customer fields
    var firstName: String?
    var lastName:String?
    var phoneNumber: String?
    var email: String?
    var password: String?
    var confirmPassword: String?
    var costumerID: String?
    var date: String?
    var isTermsAndConditionChecked: Bool?
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // MARK: Initialization
    init () {
        firstName = ""
        lastName = ""
        phoneNumber = ""
        email = ""
        password = ""
        confirmPassword = ""
        
        let nsDate = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day,.month,.year], from: nsDate)
        date = (components.day?.description)!+"-"+(components.month?.description)!+"-"+(components.year?.description)!
        date = dateFormatter.string(from: nsDate)
        isTermsAndConditionChecked = false
    }
    
    
    // MARK: Validations
    /**
        Validate First name:
         - Can't be empty
         - Less than 2 char
         - Greater 15. 
         - Can contain only letters.
        - returns: "" if valid, error message otherwise
     */
    func validateFirstName() -> String {
        if firstName == "" {
            return "Your first name can not be empty."
        } else {
            if containsOnlyLetters(firstName!) == false{
                return "Only letters are allowed"
            }
            else if firstName!.characters.count < 2 {
                return "Your first name can not be less than 2 characters."
            } else if firstName!.characters.count > 15 {
                return "Your first name can not longer."
            }
            return ""
        }
    }
    
    
    
    /**
     Validate Last name:
      - Can't be empty
      - Less than 2 char
      - Greater 15. 
      - Can contain only letters.
     - returns: "" if valid, error message otherwise
     */
    func validateLastName() -> String {
        if lastName == "" {
            return "Your last name can not be empty."
        } else {
            if containsOnlyLetters(lastName!) == false{
                return "Only letters are allowed"
            } else if lastName!.characters.count < 2 {
                return "Your last name can not be less than 2 characters."
            } else if lastName!.characters.count > 15 {
                return "Your last name can not longer."
            } else {
                return ""
            }
        }
    }
    
    /**
     Check string if it contains only letters.
     - parameter input: string about to be checked
     - returns: true or false
     */
    func containsOnlyLetters(_ input: String) -> Bool {
        for chr in input.characters {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                return false
            }
        }
        return true
    }
    
    /**
        Validate Phone number:
         - Exactly 10 digit number
         - Only contains numbers
         - Can not be empty
        - returns: "" if valid, error message otherwise
     */
    func validatePhoneNumber() -> String {
        if phoneNumber == "" {
            return "Your phone number can not be empty."
        } else {
            if (doStringContainsNumber(number: phoneNumber!)) == true {
                if phoneNumber!.characters.count < 10 || phoneNumber!.characters.count > 10 {
                    return "Your phone number has to be 10 digit number."
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
    
    /**
        Validate email:
         - Can not be empty
         - Check if string matches email format.
        - returns: "" if valid, error message otherwise
     */
    func validateEmail() -> String {
        if email == "" {
            return "Your email can not be empty."
        } else {
            if isValidEmail(email!) == false {
                return "Your email has to mach format: abc@abc.abc"
            } else {
                return ""
            }
        }
    }
    
    /**
        Check given string if it matches email format.
        - parameter testStr: string about to be checked
        - returns: true pr false
     */
    fileprivate func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    /**
        Validate password:
         - Can not be empty
         - Not less than 8 chars
         - Not greater than 14 chars
        - returns: "" if valid, error message otherwise
     */
    func validatePassword() -> String {
        if password == "" {
            return "Your password can not be empty."
        } else {
            if password!.characters.count < 8 || password!.characters.count > 14 {
                return "Your password must be between 8 to 14 characters."
            } else {
                return ""
            }
        }
    }
    
    /**
        Validate Confimr password:
         - Can not be empty
         - Has to match new Password
        - returns: "" if valid, error message otherwise
     */
    func validateConfirmPassword() -> String {
        if confirmPassword == password {
            return ""
        } else {
            return "Your password do not match."
        }
    }
    
    /**
        Validate Terms and Conditions.
        - returns: "" if isChecked, error message otherwise
     */
    func validateTermsAndConditions() -> String{
        if isTermsAndConditionChecked! {
            return ""
        } else {
            return "No"
        }
    }
    
    /**
        Validate customer:
        - validateFirstName() shoud return ""
        - validateLastName() shoud return ""
        - validatePhoneNumber() shoud return ""
        - validateEmail() shoud return ""
        - validatePassword() shoud return ""
        - validateTermsAndConditions() shoud return ""
        - returns: "" if all sections are valid, combined error message otherwise
     */
    func validateCustomer() -> String {
        return ""+validateFirstName()+validateLastName()+validatePhoneNumber()+validateEmail()+validatePassword()+validateConfirmPassword()+validateTermsAndConditions()
    }
    
}

