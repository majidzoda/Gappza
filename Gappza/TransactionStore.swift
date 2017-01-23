//
//  TransactionStore.swift
//  Gappza
//
//  Created by Firdavsii Majidzoda on 11/8/16.
//  Copyright © 2016 Gappza. All rights reserved.
//


import Alamofire

class TransactionStore {
    
    // Transactions array
    var allTransactions:[Transaction] = []
    
    // Creating new transaction and add it to array
    /**
        Create new transaction and add it transactions array.
        - parameter number: for transaction
        - parameter date: for trnsaction
        - parameter amount: for transaction
        - paremeter status: for transaction
        - returns: Transaction
     */
    func createTransaction(number: String, date: String, amount:String, status: String) -> Transaction {
        let newtransaction = Transaction(number: number, amount: amount, date: date, status:status)
        allTransactions.append(newtransaction)
        return newtransaction
    }
    
    /**
        Get transactions for current user.
     */
    func getTransactions(_ email: String, completion: @escaping ([String: AnyObject]) -> Void){
        var result: [String: AnyObject] = [:]
        
        Alamofire.request(GapzaAPI.appnameURL(method:  .getTransactions), method: .post, parameters: ["email":email]).responseJSON{
            response in
            
            // Checking if we have a successful result
            guard response.result.isSuccess else {
                // Unsuccessful query
                result["status"] = "-1" as AnyObject?
                result["errorMessage"] = "Unexpected error occured, please try again later" as AnyObject?
                completion(result)
                return
            }
            
            do {
                if let jsonData = response.data{
                    // Parsing response to JSON
                    let jsonBody = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject]
                    // Getting status and transactions array
                    guard let status = jsonBody?["status"] as? String,
                          let transactionsArray = jsonBody?["transactions"] as? [[String: AnyObject]] else {
                            // Can't get status and array
                            result["status"] = "-1" as AnyObject?
                            return
                    }
                    result["status"] = status as AnyObject?
                    result["transactionsArray"] = transactionsArray as AnyObject?
                }
            } catch {
                // Can't parse response to JSON
                result["status"] = "-1" as AnyObject?
            }
            completion(result)
        }
    }
}

