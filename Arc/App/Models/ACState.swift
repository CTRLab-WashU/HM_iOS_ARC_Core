//
//  ACState.swift
//  Arc
//
//  Created by Philip Hayes on 11/9/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
public enum ACState : String, State, CaseIterable {
	
	
	case about, auth, schedule, home, context, gridTest, priceTest, symbolsTest, changeSchedule, contact, rescheduleAvailability, testIntro, thankYou, changeStudyStart
	
	static var startup:[ACState] { return [.auth, .schedule, .home] }
	
	static var configuration: [ACState] {return [] }
	
	static var surveys:[ACState] { return  [.context] }
	
	static var tests:[ACState] {return [.gridTest, .priceTest, .symbolsTest] }
	static public var testCount = 0

	
	public func surveyTypeForState() -> SurveyType {
		return SurveyType(rawValue: self.rawValue) ?? .unknown
	}
	
	public func viewForState() -> UIViewController {
		
		let home:UIViewController = UIViewController()
		
		var newController:UIViewController = home
		
		switch self {
			
		case .about:
			newController = UIViewController()
		case .auth :
            
           break
			
			
		case .context:
			let controller:SurveyNavigationViewController = .get()
			controller.participantId = Arc.shared.participantId
			controller.surveyType = .context
			controller.loadSurvey(template: "context")
			
			newController = controller
			
			
			
        case .schedule, .changeSchedule:
            let controller:ACScheduleViewController = .init(file: "schedule")
            controller.participantId = Arc.shared.participantId
            if (self == .changeSchedule) {
                controller.isChangingSchedule = true
            }
            
            return controller
			

        case .changeStudyStart:
            let controller:StartDateShiftViewController = .get()
            controller.surveyType = .schedule
            controller.loadSurvey(template: "changeStartDate")
            return controller

		case .contact:
			let controller:ACContactNavigationController = .get()
			let window = UIApplication.shared.keyWindow
			
			
			let _ = window!.rootViewController
			//			controller.returnVC = vc!
			newController = controller
			
		case .rescheduleAvailability:
			let controller:ACAvailbilityNavigationController = .get()
			newController = controller
			
		case .testIntro:
			let controller:InstructionNavigationController = .get()
			controller.nextState = Arc.shared.appNavigation.nextAvailableSurveyState()
			
			controller.load(instructions: "TestingIntro")
			newController = controller
		case .gridTest:
			let vc:GridTestViewController = .get()
			
			let controller:InstructionNavigationController = .get()
			controller.nextVc = vc
			controller.titleOverride = "Test \(ACState.testCount) of 3"
			
			controller.load(instructions: "TestingIntro-Grids")
			newController = controller
			
		case .priceTest:
			
			let vc:PricesTestViewController = .get()
			let controller:InstructionNavigationController = .get()
			controller.nextVc = vc
			controller.titleOverride = "Test \(ACState.testCount) of 3"
			
			controller.load(instructions: "TestingIntro-Prices")
			
			newController = controller
		case .symbolsTest:
			
			let vc:SymbolsTestViewController = .get()
			let controller:InstructionNavigationController = .get()
			controller.nextVc = vc
			controller.titleOverride = "Test \(ACState.testCount) of 3"
			
			controller.load(instructions: "TestingIntro-Symbols")
			
			newController = controller
		case .home:
			break
		case .thankYou:
			let vc:FinishedNavigationController = .get()
			vc.loadSurvey(template: "finished")
			ACState.testCount = 0
			newController = vc
		
		}
		return newController

	}
	
}
