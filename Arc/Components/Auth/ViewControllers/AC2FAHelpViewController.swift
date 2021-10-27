//
//  AC2FAHelpViewController.swift
//  Arc
//
//  Created by Spencer King on 9/10/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit



class AC2FAHelpViewController: UIViewController {

    @IBOutlet weak var backButton: HMMarkupButton!
    @IBOutlet weak var headerLabel: ACLabel!
    @IBOutlet weak var answerLabel: HMMarkupLabel!
 
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        self.backButton.addAction {
            self.navigationController?.popViewController(animated: true);
        }
        
        self.headerLabel.text = "faq_tech_q5"
        self.answerLabel.text = "faq_tech_a5"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
