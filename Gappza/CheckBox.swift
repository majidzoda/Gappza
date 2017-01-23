//
//  CheckBox.swift
//  Gappza
//
//  Created by Firdavsii Majidzoda on 11/8/16.
//  Copyright © 2016 Gappza. All rights reserved.
//

import Foundation

class CheckBox {
    // MARK: Check Box fields
    var isChecked:Bool!
    var checkBoxArchieve: URL!
    
    
    // Additional archeve fields
    var additionalArchieveValue: String!
    var hasAdditionalArchieve:Bool!
    var additionalArchieve: URL!
    
    
    // Initialization
    init(archieveName: String, hasAdditionalArchieve: Bool){
        checkBoxArchieve = getArchieveUrl(archieveName: archieveName)
        additionalArchieveValue = ""
        self.hasAdditionalArchieve = hasAdditionalArchieve
        self.isChecked = loadCheckBoxValue()
    }
    
    convenience init(archieveName: String, additionalArchieve: String){
        self.init(archieveName: archieveName, hasAdditionalArchieve: true)
        self.additionalArchieve = getArchieveUrl(archieveName: additionalArchieve)
        additionalArchieveValue = loadAdditionalArchieve()
    }
    
    // MARK: Check Box load and save
    /**
        Load CheckBox checked state
         - returns: true or false
     */
    func loadCheckBoxValue() -> Bool{
        if loadArchieve(checkBoxArchieve) as! Bool{
            return true
        } else {
            return false
        }
    }
    
    /**
        Save CheckBox checked state
         - parameter bool:isChecked
     */
    func saveCheckBoxValue(bool: Bool){
        isChecked = bool
        saveArchieve(bool as AnyObject, path: checkBoxArchieve)
    }
    
    
    
    // MARK: Additional Archieve load and save
    /**
        Load additional associated CheckBox value.
         - returns: "" default, string value otherwise
     */
    func loadAdditionalArchieve() -> String{
        if isChecked! {
            return loadArchieve(additionalArchieve) as! String
        } else {
            return ""
        }
    }
    
    /**
        Save additional associated CheckBox value.
         - parameter archieveValue: -string value to be saved.
     */
    func saveAdditionalArchieve(archieveValue: String){
        if isChecked! {
            additionalArchieveValue = archieveValue
            saveArchieve(archieveValue as AnyObject, path: additionalArchieve)
        }
    }
    

    // MARK: Generic
    /**
      Get archive directory from sandbox
     */
    fileprivate func getArchieveUrl(archieveName: String) -> URL{
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory,in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent(archieveName)
    }
    
    /**
       Load archive from given directory
        - parameter path: for archive to be loaded
     */
    fileprivate func loadArchieve(_ path: URL) -> AnyObject{
        if path == checkBoxArchieve{
            guard let archieveValue = NSKeyedUnarchiver.unarchiveObject(withFile: path.path) as? Bool else {
                return false as AnyObject
            }
            return archieveValue as AnyObject
        } else {
            guard let archieveValue = NSKeyedUnarchiver.unarchiveObject(withFile: path.path) as? String else {
                return "" as AnyObject
            }
            return archieveValue as AnyObject
        }
    }
    
    /**
        Save object in given archve directory
         - parameter object: to be saved
         - parameter path: for saving directory
     */
    fileprivate func saveArchieve(_ object: AnyObject, path: URL) {
        NSKeyedArchiver.archiveRootObject(object, toFile: path.path)
    }
}

