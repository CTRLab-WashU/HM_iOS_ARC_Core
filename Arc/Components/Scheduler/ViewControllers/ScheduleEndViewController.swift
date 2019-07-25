//
//  ScheduleEndViewController.swift
//  Arc
//
//  Created by Michael Votaw on 7/24/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import HMMarkup

class ScheduleEndViewController: UIViewController {

    @IBOutlet weak var message: HMMarkupLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let participantId = Arc.shared.participantId, let schedule = Arc.shared.scheduleController.get(confirmedSchedule: participantId)
        {

        }
    }

    @IBAction func backPressed(_ sender: Any) {
    }
    
    
    @IBAction func changeTimesPressed(_ sender: Any) {
    }
    
    @IBAction func okayPressed(_ sender: Any) {
    }
    
    
    
}
