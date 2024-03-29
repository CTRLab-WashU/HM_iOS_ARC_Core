//
//  ACChangeAvailabilityViewController.swift
//  Arc
//
//  Created by Philip Hayes on 3/12/19.
//  Copyright © 2019 healthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
import HMMarkup
open class ACChangeAvailabilityViewController: UIViewController {
    public var returnState:State = Arc.shared.appNavigation.previousState() ?? Arc.shared.appNavigation.defaultState()
    public var returnVC:UIViewController?
    
    public var studyChangeView:UIView!
    
    @IBOutlet weak var studyPeriodAdjustView: UIStackView!
    
    @IBOutlet weak var changeTimeButton: ACButton!
    
    @IBOutlet weak var changeDateButton: ACButton!
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Arc.shared.studyController.getCurrentStudyPeriod() != nil {
            studyPeriodAdjustView.isHidden = true
        }
        if let config = HMMarkupRenderer.config, config.shouldTranslate {
            changeTimeButton.setTitle("CHANGE".localized("change_button"), for: .normal)
            changeDateButton.setTitle("CHANGE".localized("change_button"), for: .normal)

        }
    }
    @IBAction public func goBackPressed(_ sender: Any) {
        if let vc = returnVC {
            Arc.shared.appNavigation.navigate(vc: vc, direction: .toLeft)
        } else {
            Arc.shared.appNavigation.navigate(state: returnState, direction: .toLeft)
        }
    }
    @IBAction public func changeSchedulePressed(_ sender: UIButton) {
        Arc.shared.appNavigation.navigate(state: ACState.changeSchedule, direction: .toRight)

    }
    @IBAction public func changeStudyDatesPressed(_ sender: UIButton) {
        Arc.shared.appNavigation.navigate(state: ACState.changeStudyStart, direction: .toRight)

    }
    
   
}

open class ACAvailbilityNavigationController:UINavigationController {
    public var prev:UIViewController?
    weak var vc:ACChangeAvailabilityViewController! = nil
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        let v:ACChangeAvailabilityViewController = .get()
        vc = v
        
        pushViewController(vc, animated: true)
        navigationBar.isHidden = true
        // Do any additional setup after loading the view.
    }
    override open func viewDidAppear(_ animated: Bool) {
        vc.returnVC = prev
        super.viewDidAppear(animated)
    }

}
