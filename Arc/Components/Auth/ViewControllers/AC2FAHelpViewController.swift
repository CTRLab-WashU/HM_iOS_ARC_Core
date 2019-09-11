//
//  AC2FAHelpViewController.swift
//  Arc
//
//  Created by Spencer King on 9/10/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import HMMarkup
import ArcUIKit

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
        
//        self.headerLabel.text = question.question;
        self.headerLabel.text = "How do I resolve two-step verification issues?"
//        self.answerLabel.text = question.answer;
        self.answerLabel.text = "Steps for how to resolve those issues go here when we have copy"
    }
    
}
