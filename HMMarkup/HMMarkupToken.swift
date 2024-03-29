//
//  HMMarkupToken.swift
//  HMMarkup
//
//  Created by Philip Hayes on 11/14/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
enum HMMarkupToken {
	case text(String)
	case leftDelimiter(UnicodeScalar)
	case rightDelimiter(UnicodeScalar)
}

extension HMMarkupToken: Equatable {

}

extension HMMarkupToken: CustomStringConvertible {
	var description: String {
		switch self {
		case .text(let value):
			return value
		case .leftDelimiter(let value):
			return String(value)
		case .rightDelimiter(let value):
			return String(value)
		}
	}
}

extension HMMarkupToken: CustomDebugStringConvertible {
	var debugDescription: String {
		switch self {
		case .text(let value):
			return "text(\(value))"
		case .leftDelimiter(let value):
			return "leftDelimiter(\(value))"
		case .rightDelimiter(let value):
			return "rightDelimiter(\(value))"
		}
	}
}
