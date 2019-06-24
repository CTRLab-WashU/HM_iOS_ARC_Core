//
//  HMAPI.swift
// Arc
//
//  Created by Philip Hayes on 9/25/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
open class HMAPI {
    static public var baseUrl = ""
    static public let shared = HMAPI()

    public var clientId:String?
    
    
    public init() {
        HMRestAPI.shared.setBaseURL(url: HMAPI.baseUrl)
		clientId = Arc.shared.deviceId
    }
    
    static public let deviceRegistration:HMAPIRequest<AuthCredentials, HMResponse> = .post("device-registration")
	static public let deviceHeartbeat:HMAPIRequest<HeartbeatRequestData, HMResponse> = .post("device-heartbeat")
	

	static public let submitWakeSleepSchedule:HMAPIRequest<WakeSleepScheduleRequestData, HMResponse> = .post("submit-wake-sleep-schedule")
	
	
	static public let getSessionInfo:HMAPIRequest<Data, SessionInfoResponse> = .get("get-session-info")
	static public let getTestSchedule:HMAPIRequest<Data, TestScheduleRequestData.Response> = .get("get-test-schedule")
	static public let getWakeSleep:HMAPIRequest<Data, WakeSleepScheduleRequestData.Response> = .get("get-wake-sleep-schedule")

	

}
