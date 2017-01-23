//
//  PrivacyPolicyViewController.swift
//  Gappza
//
//  Created by Firdavsii Majidzoda on 11/12/16.
//  Copyright © 2016 Gappza. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController, UIWebViewDelegate {
    
    // Outlets
    @IBOutlet var webView: UIWebView!
    
    // Variables
    var newCustomer: Customer!
    
    // Segue configuration
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromPrivacyPolicyVCtoSignUpVC" {
            let destinationVC = segue.destination as? SignUpViewController
            destinationVC?.loadCustomer = true
            newCustomer.password = ""
            newCustomer.confirmPassword = ""
            destinationVC?.newCostumer = self.newCustomer
        }
    }
    
    
}
