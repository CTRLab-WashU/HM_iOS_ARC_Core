//
//  EarningsViewController.swift
//  Arc
//
//  Created by Philip Hayes on 8/14/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit

public class EarningsViewController: CustomViewController<ACEarningsView> {
	var thisStudy:ThisStudyExpressible = Arc.shared.studyController
	var lastUpdated:TimeInterval?
	var earningsData:EarningOverview?
	var dateFormatter = DateFormatter()
	override public func viewDidLoad() {
		
        super.viewDidLoad()
		dateFormatter.locale = app.appController.locale.getLocale()
		dateFormatter.setLocalizedDateFormatFromTemplate("MMM dd 'at' hh:mm a")
		NotificationCenter.default.addObserver(self, selector: #selector(updateEarnings(notification:)), name: .ACEarningsUpdated, object: nil)
		lastUpdated = app.appController.lastFetched["EarningsOverview"]
		earningsData = Arc.shared.appController.read(key: "EarningsOverview")
		
        // Do any additional setup after loading the view.
		setGoals()
		
    }
	@objc public func updateEarnings(notification:Notification) {
		lastUpdated = app.appController.lastFetched["EarningsOverview"]
		earningsData = Arc.shared.appController.read(key: "EarningsOverview")

	}
	
	fileprivate func updateBodyText() {
		if let last = lastUpdated {
			let date = Date(timeIntervalSince1970: last)
			if date.addingMinutes(minutes: 1).minutes(from: Date()) < 1 {
				customView.lastSyncedLabel.text = "\("".localized(ACTranslationKey.earnings_sync)) \(dateFormatter.string(from: date))"
			}
		}
		customView.bonusGoalsBodyLabel.text = "".localized(ACTranslationKey.earnings_bonus_body)
		
		switch thisStudy.studyState {
		case .baseline:
			customView.earningsBodyLabel.text = "".localized(ACTranslationKey.earnings_body0)
			
			break
		default:
			customView.earningsBodyLabel.text = "".localized(ACTranslationKey.earnings_body1)
			
			
			break
		}
	}
	
	public func setGoals() {
		
		
		updateBodyText()
		
		guard let earnings = earningsData?.response?.earnings else {
			return
		}
		customView.thisWeeksEarningsLabel.text = earnings.total_earnings
		customView.thisStudysEarningsLabel.text = earnings.cycle_earnings
		
		
		if let fourOfFourGoal = earnings.goals["4-out-of-4"] {
			
			let components = fourOfFourGoal.progress_components.sorted {
				$0.key < $1.key
			}
			
			for component in components.enumerated() {
				let index = component.offset
				let value = component.element.value
				customView.fourofFourGoal.set(progress:Double(value)/100.0, for: index)
			}
			
			customView.fourofFourGoal.set(isUnlocked: fourOfFourGoal.completed)
			customView.fourofFourGoal.set(bodyText: "".localized(ACTranslationKey.earnings_21tests_body)
				.replacingOccurrences(of: "{AMOUNT}", with: fourOfFourGoal.value))
			customView.fourofFourGoal.goalRewardView.set(text: fourOfFourGoal.value)

		}
		
		if let twoADay = earnings.goals["2-a-day"] {
			let components = twoADay.progress_components.sorted {
				$0.key < $1.key
			}
			for component in components.enumerated() {
				let index = component.offset
				let value = component.element.value
				customView.twoADayGoal.set(progress:Double(min(2, value))/2.0, forIndex: index)
			}
			customView.twoADayGoal.set(isUnlocked: twoADay.completed)
			customView.twoADayGoal.set(bodyText: "".localized(ACTranslationKey.earnings_21tests_body)
				.replacingOccurrences(of: "{AMOUNT}", with: twoADay.value))
			customView.twoADayGoal.goalRewardView.set(text: twoADay.value)

		}
		
		if let totalSessions = earnings.goals["21-sessions"] {
			
			for component in totalSessions.progress_components.enumerated() {
				let value = component.element.value
				customView.totalSessionsGoal.set(total: 21.0)
				customView.totalSessionsGoal.set(current: value)

			}
			customView.totalSessionsGoal.set(isUnlocked: totalSessions.completed)
			customView.totalSessionsGoal.set(bodyText: "".localized(ACTranslationKey.earnings_21tests_body)
				.replacingOccurrences(of: "{AMOUNT}", with: totalSessions.value))
			customView.totalSessionsGoal.goalRewardView.set(text: totalSessions.value)

		}
	}
	
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
