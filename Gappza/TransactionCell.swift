//
//  TransactionCell.swift
//  Gappza
//
//  Created by Firdavsii Majidzoda on 11/8/16.
//  Copyright © 2016 Gappza. All rights reserved.
//

import Alamofire
import SwiftyXMLParser
import CryptoSwift

class TransactionCell: UITableViewCell {
    
    // Outlets
    @IBOutlet var number: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var amount: UILabel!
    @IBOutlet var status: UILabel!
    var emonPaymentID: String?
    
    /**
        Updates cell, setting the followings:
        - number
        - amount
        - status
        - -date
     */
    private func updateCell() {
        let bodyFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        number.font = bodyFont
        amount.font = bodyFont
        status.font = bodyFont
        
        let caption1Font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        date.font = caption1Font
    }
}

