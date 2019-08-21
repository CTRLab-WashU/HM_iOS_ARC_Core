//
//  EndOfFirstTestProgressViewController.swift
//  Arc
//
//  Created by Philip Hayes on 8/1/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit

public class ACTodayProgressViewController: CustomViewController<ACTodayProgressView>, ACTodayProgressViewDelegate {
	
	
	
	public init() {
		super.init(nibName: nil, bundle: nil)
		set(flag: .baseline_completed)
		//Todo: Have this injected instead this behavior is needed elsewhere in the app.
		guard let config = Arc.shared.studyController.todaysProgress() else {
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
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

