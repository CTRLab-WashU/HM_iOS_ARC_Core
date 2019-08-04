//
//  EndOfFirstTestProgressViewController.swift
//  Arc
//
//  Created by Philip Hayes on 8/1/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit

public class ACTodayProgressViewController: CustomViewController<ACTodayProgressView>, ACTodayProgressViewDelegate {
	
	
	public struct Config{
		public struct SessionData {
			public var started:Bool = false
			public var progress:Int = 0
			public var total:Int = 3
		}
		
		
		
		public var sessionsCompleted:Int {
			var complete:Int = 0
			for session in sessionData {
				if session.progress == session.total {
					complete += 1
				}
			}
			return complete
		}
		
		
		public var sessionsStarted:Int {
			var started:Int = 0
			for session in sessionData {
				if session.started == true {
					started += 1
				}
			}
			return started
		}
		
		public var totalSessions:Int = 4
		public var sessionData:[SessionData] = []
		public init() {
			
		}
		
	}
	public init() {
		super.init(nibName: nil, bundle: nil)
		guard let config = ACTodayProgressViewController.todaysProgress() else {
			return
		}
		customView.delegate = self
		let isComplete = config.sessionsStarted == config.totalSessions
		if isComplete {
			customView.set(completed: true)
			customView.set(sessionsCompleted: config.sessionsCompleted)
			customView.set(sessionsRemaining: nil)
		} else {
			customView.set(completed: false)
			customView.set(sessionsCompleted: config.sessionsCompleted)
			customView.set(sessionsRemaining: config.totalSessions - config.sessionsStarted)
		}
		
		for index in 0 ..< config.sessionData.count {
			let session = config.sessionData[index]
			
			customView.set(progress: Double(session.progress)/Double(session.total),
						   for: index)
		}
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
    }
	
	public func nextPressed() {
		Arc.shared.nextAvailableState()
	}
	static public func todaysProgress() -> Config? {
		let c = Arc.shared.studyController
		guard let study = c.getCurrentStudyPeriod() else {
			return nil
		}
		var config = ACTodayProgressViewController.Config()
		
		guard let currentSessionId = Arc.shared.currentTestSession else {
			assertionFailure("No session running, add code to fetch previous session.")
			return nil
		}
		let currentSession = c.get(session: currentSessionId)
		var sessions = c.get(allSessionsForStudy: Int(study.studyID	))
		if let d = currentSession?.sessionDayIndex {
			sessions = sessions.filter {
				return $0.sessionDayIndex == d
			}
		}
		config.totalSessions = sessions.count

		for sessionData in sessions {
			let day = Int(sessionData.day)
			
			
			let studyId = Int(study.studyID)
			let week = Int(sessionData.week)
			let session = Int(sessionData.session)
			var progress = 0
			var totalTest = 3
			
			if c.get(numberOfTestTakenOfType: .priceTest,
				   inStudy: studyId,
				   week:week,
				   day:day,
				   session: session) != 0 {
				progress += 1
			}
			if c.get(numberOfTestTakenOfType: .gridTest,
					 inStudy: studyId,
					 week:week,
					 day:day,
					 session: session) != 0 {
				progress += 1
			}
			if c.get(numberOfTestTakenOfType: .symbolsTest,
					 inStudy: studyId,
					 week:week,
					 day:day,
					 session: session) != 0 {
				progress += 1
			}
			let started = (sessionData.missedSession || sessionData.startTime != nil || sessionData.expirationDate!.addingHours(hours: 2).timeIntervalSince1970 < Date().timeIntervalSince1970)
			
			config.sessionData.append(ACTodayProgressViewController.Config.SessionData(started:started,
																					   progress: progress,
																					   total: totalTest))
		}
		
		return config
		
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

