//
//  ScheduleEndViewController.swift
//  Arc
//
//  Created by Michael Votaw on 7/24/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import HMMarkup
import ArcUIKit
open class ScheduleEndViewController: UIViewController, SurveyInput {
    

    @IBOutlet weak var changeTimesButton: HMMarkupButton!
    @IBOutlet weak var okayButton: ACButton!
    @IBOutlet weak var message: HMMarkupLabel!
    
    private var isReschedule: Bool = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: changeTimesButton.titleLabel?.text ?? "", attributes: underlineAttribute)
        changeTimesButton.titleLabel?.attributedText = underlineAttributedString
        if let participantId = Arc.shared.participantId, let schedule = Arc.shared.scheduleController.get(confirmedSchedule: participantId), let s = schedule.entries.first
        {
            self.message.template = ["TIME1": s.availabilityStart!, "TIME2": s.availabilityEnd!];
            if isReschedule {
                self.message.text = "availability_change_confirm";
            } else {
                self.message.text = "availability_confirm";
            }
        }
    }

    @IBAction func changeTimesPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true);
    }
    
    @IBAction func okayPressed(_ sender: Any) {
        self.okayButton.isEnabled = false;
        self.surveyInputDelegate?.nextPressed(input: nil, value: nil);
    }
    
    
    public func getValue() -> QuestionResponse? {
        return nil;
    }
    
    public func setValue(_ value: QuestionResponse?) {
    }
    
    public func setIsRescheduling() {
        isReschedule = true
    }
    
    public var orientation: UIStackView.Alignment = UIStackView.Alignment.bottom
    
    public var surveyInputDelegate: SurveyInputDelegate?;
    
    
}
