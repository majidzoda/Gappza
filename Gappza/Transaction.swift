//
//  Transaction.swift
//  Gappza
//
//  Created by Firdavsii Majidzoda on 11/8/16.
//  Copyright © 2016 Gappza. All rights reserved.
//

import Foundation

class Transaction: NSObject {
    
    // Fields
    let number: String
    let amount: String
    let date: String
    let status: String
    
    // Initialazation
    init(number: String, amount: String, date: String, status: String) {
        self.number = number
        self.amount = amount
        self .date = date
        self.status = status
    }
}

