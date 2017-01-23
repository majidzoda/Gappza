//
//  User.swift
//  Gappza
//
//  Created by Firdavsii Majidzoda on 11/8/16.
//  Copyright © 2016 Gappza. All rights reserved.
//

import UIKit

struct User {
    
    // Directory for user's email
    fileprivate let currentUserEmailArchieve: URL = {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("currenctUserEmail.archive")
    }()
    
    // Directory for user's first name
    fileprivate let currentUserFirstNameArchieve: URL = {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("currenctUserFirstName.archive")
    }()
    
    /**
        Load user's saved email
         - returns: email -string
     */
    func loadCurrentUserEmail() -> String{
        return (NSKeyedUnarchiver.unarchiveObject(withFile: currentUserEmailArchieve.path) as? String)!
    }
    
    /**
        Save user's email.
         - parameter email: to be saved
     */
    func saveEmailForCurrentUser(email: String){
        NSKeyedArchiver.archiveRootObject(email, toFile: currentUserEmailArchieve.path)
    }
    
    /**
        Load user's first name
         - returns: First namee -string
     */
    func loadCurrentUserFirstName() -> String{
        return (NSKeyedUnarchiver.unarchiveObject(withFile: currentUserFirstNameArchieve.path) as? String)!
    }
    
    /**
        Save user's first name
         - parameter firstName: First nane to be saved
     */
    func saveFirstNameForCurrentUser(firstName: String){
        NSKeyedArchiver.archiveRootObject(firstName, toFile: currentUserFirstNameArchieve.path)
    }
    
}

