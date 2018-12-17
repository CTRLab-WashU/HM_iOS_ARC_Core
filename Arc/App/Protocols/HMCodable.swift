//
//  HMCodable.swift
// Arc
//
//  Created by Philip Hayes on 9/27/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
/*
 This is simply for objects that will be stored in core data
 as JSONData objects.
 
 */

public protocol HMCodable : Codable {
    var id : String? {get set}
	var type : SurveyType? {get set}
	static var dataType: SurveyType {get}

}

public protocol HMTestCodable : HMCodable {
    var date:TimeInterval? {get set}
}
