//
//  TodaysProgress.swift
//  Arc
//
//  Created by Philip Hayes on 8/21/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation
public struct TodaysProgess {
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
