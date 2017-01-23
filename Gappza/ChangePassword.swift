//
//  ChangePassword.swift
//  Gapza
//
//  Created by Firdavsii Majidzoda on 11/8/16.
//  Copyright © 2016 Gappza. All rights reserved.
//

class ChangePassword {
    
    // MARK: Fields
    var currentPassword: String?
    var newPassword: String?
    var confirmNewPassword: String?
    
    // Initialization
    init(){
        currentPassword = ""
        newPassword = ""
        confirmNewPassword = ""
    }
    
    // MARK Validate Current Password Configuration
    /**
        Validate Current Password:
         - Can not be empty
         - returns: "" if valid, error message otherwise
     */
    func validateCurrentPassword() -> String {
        if currentPassword == ""{
            return "Your current password can not be empty"
        } else {
            return ""
        }
    }
    
    // MARK Validate New Password Configuration
    /**
     Validate New Password:
     - Can not be empty
     - Can't be less than 8 charaters
     - Can't be greater than 14 characters
     - returns: "" if valid, error message otherwise
     */
    func validateNewPassword() -> String {
        if newPassword == "" {
            return "Your password can not be empty."
        } else {
            if newPassword!.characters.count < 8 || newPassword!.characters.count > 14 {
                return "Your password must be between 8 to 14 characters."
            } else {
                return ""
            }
        }
    }
    
    // MARK Validate Confirm Password Configuration
    /**
     Validate Confirm Password:
     - Should match new Password
     - returns: "" if valid, error message otherwise
     */
    func validateConfirmNewPassword() -> String {
        if confirmNewPassword == newPassword {
            return ""
        } else {
            return "Your password do not match."
        }
    }
    
    // MARK Validate changePassword Configuration
    /**
     Validate  changePassword:
     - validateCurrentPassword() should return ""
     - validateNewPassword() should return ""
     - validateConfirmNewPassword() should return ::
     - returns: "" if valid, combined error message otherwise
     */
    func validateChangePassword() -> String {
        return validateCurrentPassword()+validateNewPassword()+validateConfirmNewPassword()
    }
}
