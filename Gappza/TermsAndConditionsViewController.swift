//
//  TermsAndConditionsViewController.swift
//  Gappza
//
//  Created by Firdavsii Majidzoda on 11/12/16.
//  Copyright © 2016 Gappza. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {
    
    // Outlets
    @IBOutlet var scrollView: UITextView!
    
    // Variables
    var newCustomer: Customer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.flashScrollIndicators()
    }
    
    // Segue configuration
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromTermsAndConditionsVCtoSignUpVC" {
            let destinationVC = segue.destination as? SignUpViewController
            destinationVC?.loadCustomer = true
            newCustomer.password = ""
            newCustomer.confirmPassword = ""
            destinationVC?.newCostumer = self.newCustomer
        }
    }
}
