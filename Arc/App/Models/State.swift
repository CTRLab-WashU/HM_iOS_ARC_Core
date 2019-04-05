//
//  State.swift
//  Arc
//
//  Created by Philip Hayes on 11/9/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
public protocol State {
	
	func viewForState() -> UIViewController
	func surveyTypeForState() -> SurveyType
}
