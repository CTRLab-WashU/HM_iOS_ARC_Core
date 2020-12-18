//
//  AuthDetailsRequest.swift
//  Arc
//
//  Created by Philip Hayes on 12/16/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//

import Foundation
/**
 POST /request-auth-details
 {
 "participant_id": "123456"
 }
 */
public struct AuthDetailsRequest:Codable {

    var participant_id:String
}
