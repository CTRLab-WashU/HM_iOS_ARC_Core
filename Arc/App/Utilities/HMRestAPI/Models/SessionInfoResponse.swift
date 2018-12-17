//
//  SessionInfoResponse.swift
//  mHealth
//
//  Created by Philip Hayes on 11/29/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//
/*
{
	"response": {
		"success": true,

		"first_test": {
			"session_date": 1540505077,
			"week": 0,
			"day": 0,
			"session": 0,
			"session_id": "0"
		},

		"latest_test": {
			"session_date": 1551319989,
			"week": null,
			"day": null,
			"session": null,
			"session_id": "378"

		}
	},

	"errors": {}
}

*/

import Foundation
public struct SessionInfoResponse : Codable {
	
	public struct TestState : Codable {
		public var session_date : TimeInterval
		public var week : Int
		public var day : Int
		public var session : Int
		public var session_id : String
        
        public init() {
            session_date = Date().timeIntervalSince1970
            week = 0
            day = 0
            session = 0
            session_id = "0"
        }
        
	}
	public struct Body : Codable {
		var success : Bool?
		public var first_test : TestState?
		public var latest_test : TestState?

	}
	
	public var response:Body
	public var errors : [String:[String]]
    
    

}
