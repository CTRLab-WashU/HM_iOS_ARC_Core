//
//  ACSurveyType.swift
//  Arc
//
//  Created by Philip Hayes on 11/9/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation

public enum SurveyType : String, Codable {
	case unknown, auth, onboarding, ema, edna, mindfulness, schedule, mindfulnessReminder, context, finished, finishedPart, finishedNoQuestions, gridTest, priceTest, symbolsTest, cognitive, wake, chronotype, region, language

	public var metatype: HMCodable.Type {
		switch self {
		case .gridTest:
			return GridTestResponse.self
		case .symbolsTest:
			return GridTestResponse.self
		case .priceTest:
			return GridTestResponse.self
		case .cognitive:
			return CognitiveTest.self
		default :
			return SurveyResponse.self
		}
	}
}
