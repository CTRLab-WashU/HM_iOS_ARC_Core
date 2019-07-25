//
//  ScheduleEndViewController.swift
//  Arc
//
//  Created by Michael Votaw on 7/24/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import HMMarkup

open class ScheduleEndViewController: UIViewController, SurveyInput {
    

    @IBOutlet weak var message: HMMarkupLabel!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if let participantId = Arc.shared.participantId, let schedule = Arc.shared.scheduleController.get(confirmedSchedule: participantId), let s = schedule.entries.first
        {
            self.message.template = ["TIME1": s.availabilityStart!, "TIME2": s.availabilityEnd!];
            self.message.text = "availability_confirm";
        }
    }

    @IBAction func changeTimesPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true);
    }
    
    @IBAction func okayPressed(_ sender: Any) {
        self.inputDelegate?.nextPressed(input: nil, value: nil);
    }
    
    
    public func getValue() -> QuestionResponse? {
        return nil;
    }
    
    public func setValue(_ value: QuestionResponse?) {
    }
    
    public var orientation: UIStackView.Alignment = UIStackView.Alignment.bottom
    
    public var inputDelegate: SurveyInputDelegate?;
    
    
}
