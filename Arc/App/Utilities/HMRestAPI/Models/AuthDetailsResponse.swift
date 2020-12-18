//
//  AuthDetailsResponse.swift
//  Arc
//
//  Created by Philip Hayes on 12/16/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//

import Foundation
public enum AuthDetailType : String, Codable {
    case rater
    case confirm_code
    case manual
}
/**
 {
 "response": {
 "success": true,
 "study_name": "EEE",
 "auth_type": "rater",
 "auth_code_length": 6
 },
 "errors": {}
 }
 */
public struct AuthDetailsResponse : Codable {
    struct ResponseBody : Codable {
        var success:Bool
        var study_name:String
        var auth_type:AuthDetailType
        var auth_code_length:Int
    }


    var response:ResponseBody
    var errors:[String:[String]]

}
