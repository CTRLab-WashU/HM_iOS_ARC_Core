//
//  HMFault.swift
// Arc
//
//  Created by Philip Hayes on 9/25/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//
/*
{
"response": {
"success": false
},
"errors": {
"participant_id": [
"Invalid Participant ID or Authorization Code"
]
}
}
*/
import Foundation

public struct HMFault : Codable {
	var message:String
}

public struct HMResponse : Codable {
	
	public struct Body : Codable {
		public var success : Bool?
		public var md5:String?
	}
	
	public var response:Body?
	public var responseData:HTTPURLResponse?
	public var errors : [String:[String]]

	private enum CodingKeys : CodingKey {
		case response, errors
	}
}
